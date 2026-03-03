import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class UserManager {
  static Map<String, dynamic> _data = {};
  static bool _loaded = false;

  // 🔥 Carica users.json (con riparazione automatica)
  static Future<void> load() async {
    if (_loaded) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/users.json");

    if (!file.existsSync()) {
      // Copia il file iniziale dagli assets
      final assetData = await rootBundle.loadString("assets/users.json");
      await file.writeAsString(assetData);
    }

    final content = await file.readAsString();

    try {
      _data = jsonDecode(content);
    } catch (e) {
      // Se il file è corrotto, lo resetta
      _data = {
        "users": [],
        "currentUser": null,
      };
      await _save();
    }

    // 🔥 Se manca la lista utenti, la crea
    _data["users"] ??= [];

    // 🔥 Se manca currentUser, lo crea
    _data["currentUser"] ??= null;

    _loaded = true;
  }

  // 🔍 Restituisce il file locale
  static Future<File> getLocalUserFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/users.json");
  }

  // 💾 Salva il file JSON
  static Future<void> _save() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/users.json");
    await file.writeAsString(const JsonEncoder.withIndent("  ").convert(_data));
  }

  // 🔑 Login (password in chiaro)
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    await load();

    for (var user in _data["users"]) {
      if (user["username"] == username && user["password"] == password) {
        _data["currentUser"] = user;
        await _save();
        return user;
      }
    }
    return null;
  }

  // 🆕 Registrazione (password in chiaro)
  static Future<bool> register(String username, String password) async {
    await load();

    // Controlla se esiste già
    for (var user in _data["users"]) {
      if (user["username"] == username) return false;
    }

    final newUser = {
      "userId": DateTime.now().millisecondsSinceEpoch.toString(),
      "username": username,
      "password": password,
      "role": "user",
      "permissions": []
    };

    _data["users"].add(newUser);
    await _save();
    return true;
  }

  // 👤 Utente corrente
  static Map<String, dynamic>? currentUser() {
    return _data["currentUser"];
  }

  // 🚪 Logout
  static Future<void> logout() async {
    _data["currentUser"] = null;
    await _save();
  }

  // 🔐 Controllo permessi
  static bool canEditSite(String siteId) {
    final user = currentUser();
    if (user == null) return false;
    if (user["role"] == "admin") return true;
    return user["permissions"].contains(siteId);
  }

  // 👑 Aggiungi permesso
  static Future<void> addPermission(String userId, String siteId) async {
  await load();

  for (var user in _data["users"]) {
    if (user["userId"] == userId) {
      user["permissions"] ??= [];
      if (!user["permissions"].contains(siteId)) {
        user["permissions"].add(siteId);
      }
    }
  }

  await _save();
}
static Future<void> removePermission(String userId, String siteId) async {
  await load();

  for (var user in _data["users"]) {
    if (user["userId"] == userId) {
      user["permissions"]?.remove(siteId);
    }
  }

  await _save();
}


}
