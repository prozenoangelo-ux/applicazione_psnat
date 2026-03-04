import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseManager {
  static Map<String, dynamic> _db = {};
  static bool _loaded = false;

  // 🔥 Percorso file
  static Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/database.json");

    // Se non esiste → crea struttura iniziale
    if (!file.existsSync()) {
      await file.writeAsString(
        jsonEncode({
          "version": 1,
          "lastSync": "",
          "sites": [],
          "boxes": [],
          "items": []
        }),
      );
    }

    return file;
  }

  // 🔥 Carica database
  static Future<void> load() async {
    if (_loaded) return;

    final file = await _localFile();
    final content = await file.readAsString();

    dynamic raw;

    try {
      raw = jsonDecode(content);
    } catch (e) {
      raw = null;
    }

    if (raw is Map) {
      _db = Map<String, dynamic>.from(raw);
    } else if (raw is List && raw.isNotEmpty && raw.first is Map) {
      _db = Map<String, dynamic>.from(raw.first);
    } else {
      _db = {
        "version": 1,
        "lastSync": "",
        "sites": [],
        "boxes": [],
        "items": []
      };
    }

    // 🔥 Garantisce che le sezioni esistano
    _db["version"] ??= 1;
    _db["lastSync"] ??= "";
    _db["sites"] ??= [];
    _db["boxes"] ??= [];
    _db["items"] ??= [];

    _loaded = true;
  }

  // 🔥 Salva database
  static Future<void> save() async {
    final file = await _localFile();
    await file.writeAsString(
      const JsonEncoder.withIndent("  ").convert(_db),
    );
  }

  // 📌 GETTERS pubblici
  static Map<String, dynamic> get db => _db;
  static int get localVersion => _db["version"] ?? 1;
  static String get lastSync => _db["lastSync"] ?? "";

  static List<dynamic> get sites => _db["sites"];
  static List<dynamic> get boxes => _db["boxes"];
  static List<dynamic> get items => _db["items"];

  // 🔥 Sostituisce l'intero database (usato dalla SyncPage)
  static Future<void> replaceDatabase(Map<String, dynamic> newDb) async {
    _db = {
      "version": newDb["version"] ?? 1,
      "lastSync": newDb["lastSync"] ?? "",
      "sites": newDb["sites"] ?? [],
      "boxes": newDb["boxes"] ?? [],
      "items": newDb["items"] ?? [],
    };

    await save();
  }

  // 📌 Aggiungi sito
  static Future<void> addSite(Map<String, dynamic> site) async {
    await load();
    _db["sites"].add(site);
    await save();
  }

  // 📌 Aggiorna sito
  static Future<void> updateSite(Map<String, dynamic> site) async {
    await load();
    final index = _db["sites"].indexWhere((s) => s["siteId"] == site["siteId"]);
    if (index != -1) {
      _db["sites"][index] = site;
      await save();
    }
  }

  // 📌 Aggiungi box
  static Future<void> addBox(Map<String, dynamic> box) async {
    await load();
    _db["boxes"].add(box);
    await save();
  }

  // 📌 Aggiorna box
  static Future<void> updateBox(Map<String, dynamic> box) async {
    await load();
    final index = _db["boxes"].indexWhere((b) => b["boxId"] == box["boxId"]);
    if (index != -1) {
      _db["boxes"][index] = box;
      await save();
    }
  }

  // 📌 Elimina box
  static Future<void> deleteBox(String boxId) async {
    await load();
    _db["boxes"].removeWhere((b) => b["boxId"] == boxId);

    // 🔥 Elimina anche gli item collegati
    _db["items"].removeWhere((i) => i["boxId"] == boxId);

    await save();
  }

  // 📌 Aggiungi item
  static Future<void> addItem(Map<String, dynamic> item) async {
    await load();
    _db["items"].add(item);
    await save();
  }

  // 📌 Aggiorna item
  static Future<void> updateItem(Map<String, dynamic> item) async {
    await load();
    final index = _db["items"].indexWhere((i) => i["itemId"] == item["itemId"]);
    if (index != -1) {
      _db["items"][index] = item;
      await save();
    }
  }

  // 📌 Elimina item
  static Future<void> deleteItem(String itemId) async {
    await load();
    _db["items"].removeWhere((i) => i["itemId"] == itemId);
    await save();
  }
}
