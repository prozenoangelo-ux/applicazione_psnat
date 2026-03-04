import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applicazione_psnat/detail/database_manager.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  bool loading = false;
  String logText = "";
  int? remoteVersion;
  int? localVersion;
  DateTime? lastSync;

  final String remoteUrl = "https://TUO-SITO.COM/database.json";
  final String uploadUrl = "https://TUO-SITO.COM/upload.php";

  @override
  void initState() {
    super.initState();
    _loadLocalInfo();
  }

  Future<void> _loadLocalInfo() async {
    await DatabaseManager.load();

    setState(() {
      localVersion = DatabaseManager.localVersion;
      lastSync = DateTime.tryParse(DatabaseManager.lastSync);
    });
  }

  void _addLog(String msg) {
    setState(() {
      logText = "$msg\n$logText";
    });
  }

  // 🔥 Scarica database remoto
  Future<Map<String, dynamic>?> _downloadRemote() async {
    try {
      final response = await http.get(Uri.parse(remoteUrl));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        remoteVersion = decoded["version"] ?? 1;
        return decoded;
      }
    } catch (e) {
      _addLog("❌ Errore download: $e");
    }
    return null;
  }

  // 🔥 Carica database locale sul server
  Future<void> _uploadRemote(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(uploadUrl),
        body: {"json": jsonEncode(data)},
      );

      if (response.statusCode == 200) {
        _addLog("✔ Database caricato sul server");
      } else {
        _addLog("❌ Errore upload: ${response.statusCode}");
      }
    } catch (e) {
      _addLog("❌ Errore upload: $e");
    }
  }

  // 🔥 Merge semplice: vince updatedAt più recente
  Map<String, dynamic> _mergeDatabases(
      Map<String, dynamic> local, Map<String, dynamic> remote) {
    final merged = {
      "version": (remote["version"] ?? 1) + 1,
      "lastSync": DateTime.now().toIso8601String(),
      "sites": [],
      "boxes": [],
      "items": [],
    };

    List<dynamic> mergeList(String key) {
      final localList = (local[key] as List).map((e) => Map<String, dynamic>.from(e)).toList();
      final remoteList = (remote[key] as List).map((e) => Map<String, dynamic>.from(e)).toList();

      final Map<String, Map<String, dynamic>> map = {};

      for (var e in remoteList) {
        map[e["${key.substring(0, key.length - 1)}Id"]] = e;
      }

      for (var e in localList) {
        final id = e["${key.substring(0, key.length - 1)}Id"];
        if (!map.containsKey(id)) {
          map[id] = e;
        } else {
          final localTime = DateTime.tryParse(e["updatedAt"] ?? "") ?? DateTime(2000);
          final remoteTime = DateTime.tryParse(map[id]!["updatedAt"] ?? "") ?? DateTime(2000);

          map[id] = localTime.isAfter(remoteTime) ? e : map[id]!;
        }
      }

      return map.values.toList();
    }

    merged["sites"] = mergeList("sites");
    merged["boxes"] = mergeList("boxes");
    merged["items"] = mergeList("items");

    return merged;
  }

  // 🔥 Sincronizzazione completa
  Future<void> _syncNow() async {
    setState(() => loading = true);

    _addLog("🔄 Avvio sincronizzazione...");

    final remote = await _downloadRemote();
    if (remote == null) {
      setState(() => loading = false);
      return;
    }

    final local = DatabaseManager.db;

    _addLog("📥 Versione remota: ${remote["version"]}");
    _addLog("📦 Versione locale: ${DatabaseManager.localVersion}");

    final merged = _mergeDatabases(local, remote);

    _addLog("🔧 Merge completato");

    await _uploadRemote(merged);

    await DatabaseManager.replaceDatabase(merged);

    _addLog("💾 Database locale aggiornato");

    await _loadLocalInfo();

    setState(() => loading = false);
  }

  // 🔥 Scarica e sostituisce locale
  Future<void> _downloadOnly() async {
    setState(() => loading = true);

    final remote = await _downloadRemote();
    if (remote != null) {
      await DatabaseManager.replaceDatabase(remote);
      _addLog("📥 Database remoto scaricato e salvato");
    }

    await _loadLocalInfo();
    setState(() => loading = false);
  }

  // 🔥 Carica locale sul server
  Future<void> _uploadOnly() async {
    setState(() => loading = true);

    await _uploadRemote(DatabaseManager.db);

    _addLog("📤 Database locale caricato");

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sincronizzazione"),
        actions: const [GlobalMenuButton()],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusCard(),
                  const SizedBox(height: 20),
                  _actionsCard(),
                  const SizedBox(height: 20),
                  _logCard(),
                ],
              ),
            ),
    );
  }

  Widget _statusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Stato attuale",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Versione locale: $localVersion"),
            Text("Versione remota: ${remoteVersion ?? 'N/D'}"),
            Text("Ultima sincronizzazione: ${lastSync ?? 'N/D'}"),
          ],
        ),
      ),
    );
  }

  Widget _actionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Azioni",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _syncNow,
              child: const Text("🔄 Sincronizza ora"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _downloadOnly,
              child: const Text("📥 Scarica dal server"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _uploadOnly,
              child: const Text("📤 Carica sul server"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Log attività",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(logText.isEmpty ? "Nessuna attività" : logText),
          ],
        ),
      ),
    );
  }
}
