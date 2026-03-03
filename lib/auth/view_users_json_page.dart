
import 'package:flutter/material.dart';
import 'user_manager.dart';

class ViewUsersJsonPage extends StatefulWidget {
  const ViewUsersJsonPage({super.key});

  @override
  State<ViewUsersJsonPage> createState() => _ViewUsersJsonPageState();
}

class _ViewUsersJsonPageState extends State<ViewUsersJsonPage> {
  String content = "Caricamento...";

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    final file = await UserManager.getLocalUserFile();

    if (!file.existsSync()) {
      setState(() => content = "Il file users.json non esiste.");
      return;
    }

    final text = await file.readAsString();
    setState(() => content = text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("users.json")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          content,
          style: const TextStyle(fontSize: 16, fontFamily: "monospace"),
        ),
      ),
    );
  }
}
