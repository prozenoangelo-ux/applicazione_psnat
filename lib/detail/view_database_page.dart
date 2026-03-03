import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ViewDatabasePage extends StatefulWidget {
  const ViewDatabasePage({super.key});

  @override
  State<ViewDatabasePage> createState() => _ViewDatabasePageState();
}

class _ViewDatabasePageState extends State<ViewDatabasePage> {
  String content = "Caricamento...";

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/database.json");

    if (!file.existsSync()) {
      setState(() => content = "Il file database.json non esiste.");
      return;
    }

    final text = await file.readAsString();
    setState(() => content = text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("database.json")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "monospace",
          ),
        ),
      ),
    );
  }
}
