import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';
import 'package:applicazione_psnat/widgets/qrsavers.dart';

final GlobalKey qrKey = GlobalKey();

class NewBoxPage extends StatefulWidget {
  const NewBoxPage({super.key});

  @override
  State<NewBoxPage> createState() => _NewBoxPageState();
}

class _NewBoxPageState extends State<NewBoxPage> {
  final titoloController = TextEditingController();
  final descrizioneController = TextEditingController();

  DateTime createdAt = DateTime.now();
  String? stato;

  // 🔥 ID dinamico basato sul titolo
  String boxId = "";

  final List<String> statiBox = [
    "In lavorazione",
    "Da catalogare",
    "Completa",
    "Stoccata",
  ];

  @override
  void initState() {
    super.initState();
    stato = statiBox.first;
  }

  // 🔥 Genera ID basato sul titolo
  void _updateBoxId() {
    final titolo = titoloController.text.trim().toLowerCase();

    if (titolo.isEmpty) {
      setState(() => boxId = "");
      return;
    }

    final safeTitle = titolo.replaceAll(RegExp(r'[^a-z0-9]+'), '_');

    boxId = "${safeTitle}_${DateTime.now().millisecondsSinceEpoch}";
    setState(() {});
  }

  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile() async {
    final path = await _localPath();
    return File('$path/database.json');
  }

  Future<void> saveBox() async {
    final titolo = titoloController.text.trim();
    final descrizione = descrizioneController.text.trim();

    if (titolo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Il titolo non può essere vuoto"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (boxId.isEmpty) {
      _updateBoxId();
    }

    final newBox = {
      "boxId": boxId,
      "titolo": titolo,
      "descrizione": descrizione,
      "foto": [], // 🔥 immagini rimosse
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": createdAt.toIso8601String(),
      "stato": stato,
      "items": [],
    };

    final file = await _localFile();
    List<dynamic> data = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      data = jsonDecode(content);
    }

    data.add(newBox);

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    if (!mounted) return;
    Navigator.pop(context, newBox);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuova Box"),
        actions: const [GlobalMenuButton()],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Data creazione: $createdAt"),
            const SizedBox(height: 20),

            // 🔥 QR CODE DINAMICO
            // const Text(
            //   "QR Code",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 6),
            Center(
              child: GestureDetector(
                onTap: () => saveQrToGallery(qrKey, boxId, context),
                child: RepaintBoundary(
                  key: qrKey,
                  child: QrImageView(
                    data: boxId,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),

            Center(
              child: boxId.isEmpty
                  ? const Text("Inserisci un titolo per generare il QR")
                  : QrImageView(
                      data: boxId,
                      version: QrVersions.auto,
                      size: 160,
                      backgroundColor: Colors.white,
                    ),
            ),

            const SizedBox(height: 10),

            // 🔥 Mostra ID sotto il QR
            if (boxId.isNotEmpty)
              Center(
                child: Text(
                  "ID: $boxId",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 24),

            const Text(
              "Titolo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: titoloController,
              onChanged: (_) => _updateBoxId(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Inserisci il titolo della box",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Descrizione",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: descrizioneController,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Inserisci una descrizione",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Stato della box",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: stato,
              items: statiBox.map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (value) => setState(() => stato = value),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveBox,
                child: const Text("Crea Box"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
