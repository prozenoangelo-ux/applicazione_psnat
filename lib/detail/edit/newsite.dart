import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class NewSitePage extends StatefulWidget {
  const NewSitePage({super.key});

  @override
  State<NewSitePage> createState() => _NewSitePageState();
}

class _NewSitePageState extends State<NewSitePage> {
  final nomeController = TextEditingController();
  final descrizioneController = TextEditingController();
  final posizioneController = TextEditingController();
  final noteController = TextEditingController();

  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile() async {
    final path = await _localPath();
    return File('$path/database.json');
  }

  Future<void> saveSite() async {
    final nome = nomeController.text.trim();
    final descrizione = descrizioneController.text.trim();
    final posizione = posizioneController.text.trim();
    final note = noteController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Il nome del sito è obbligatorio"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newSite = {
      "siteId": DateTime.now().millisecondsSinceEpoch.toString(),
      "nome": nome,
      "descrizione": descrizione,
      "posizione": posizione,
      "note": note,
      "createdAt": DateTime.now().toIso8601String(),
    };

    final file = await _localFile();
    final content = await file.readAsString();
    List<dynamic> data = jsonDecode(content);

    // Sezione "sites" nel database
    Map<String, dynamic> root = data.first;
    root["sites"] ??= [];
    root["sites"].add(newSite);

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    if (!mounted) return;
    Navigator.pop(context, newSite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuovo Sito Archeologico")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nome del sito",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Es. Monte San Giorgio",
              ),
            ),

            const SizedBox(height: 20),

            const Text("Descrizione",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: descrizioneController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Descrizione del sito",
              ),
            ),

            const SizedBox(height: 20),

            const Text("Posizione",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: posizioneController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Es. Verona, Italia",
              ),
            ),

            const SizedBox(height: 20),

            const Text("Note",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Note aggiuntive",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveSite,
                child: const Text("Salva Sito"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
