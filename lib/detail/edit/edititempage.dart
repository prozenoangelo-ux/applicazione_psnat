import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';

class EditItemPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController nomeController;
  late TextEditingController descrizioneController;
  late List<File> immagini;

  // 🔥 Nuovi campi
  late DateTime createdAt;
  late DateTime updatedAt;
  List<String> selectedTags = [];
  String? stato;

  final List<String> tagDisponibili = [
    "ceramica",
    "metallo",
    "legno",
    "vetro",
    "tessuto",
    "fragile",
    "restauro",
  ];

  final List<String> statiReperto = [
    "In lavorazione",
    "Da pulire",
    "Da catalogare",
    "Pulito e catalogato",
    "Stoccato",
  ];

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(text: widget.item["nome"]);
    descrizioneController = TextEditingController(text: widget.item["descrizione"]);

    immagini = (widget.item["foto"] as List<dynamic>? ?? [])
        .map((path) => File(path))
        .toList();

    createdAt = DateTime.tryParse(widget.item["createdAt"] ?? "") ?? DateTime.now();
    updatedAt = DateTime.tryParse(widget.item["updatedAt"] ?? "") ?? DateTime.now();

    selectedTags = List<String>.from(widget.item["tags"] ?? []);
    stato = widget.item["stato"] ?? statiReperto.first;
  }

  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile() async {
    final path = await _localPath();
    return File('$path/database.json');
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final List<XFile> files = await picker.pickMultiImage();

    setState(() {
      immagini = files.map((f) => File(f.path)).toList();
    });
  }

  Future<void> saveChanges() async {
    updatedAt = DateTime.now();

    widget.item["nome"] = nomeController.text.trim();
    widget.item["descrizione"] = descrizioneController.text.trim();
    widget.item["foto"] = immagini.map((f) => f.path).toList();
    widget.item["createdAt"] = createdAt.toIso8601String();
    widget.item["updatedAt"] = updatedAt.toIso8601String();
    widget.item["tags"] = selectedTags;
    widget.item["stato"] = stato;

    final file = await _localFile();
    final content = await file.readAsString();
    List<dynamic> data = jsonDecode(content);

    for (var box in data) {
      final items = (box["items"] as List<dynamic>? ?? []);
      final index = items.indexWhere((it) => it["itemId"] == widget.item["itemId"]);
      if (index != -1) {
        items[index] = widget.item;
        break;
      }
    }

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    if (!mounted) return;
    Navigator.pop(context, widget.item);
  }

  Future<void> deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminare questo item?"),
          content: const Text("Questa azione non può essere annullata."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annulla"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Elimina", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final file = await _localFile();
    final content = await file.readAsString();
    List<dynamic> data = jsonDecode(content);

    for (var box in data) {
      final items = (box["items"] as List<dynamic>? ?? []);
      final index = items.indexWhere((it) => it["itemId"] == widget.item["itemId"]);
      if (index != -1) {
        items.removeAt(index);
        break;
      }
    }

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    if (!mounted) return;
    Navigator.pop(context, "deleted");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifica Item"),
        actions: const [
          GlobalMenuButton(),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 DATE
            Text("Creato il: ${createdAt.toLocal()}"),
            Text("Ultima modifica: ${updatedAt.toLocal()}"),
            const SizedBox(height: 20),

            // 🔥 NOME
            const Text("Nome", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            // 🔥 DESCRIZIONE
            const Text("Descrizione", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: descrizioneController,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            // 🔥 TAG
            const Text("Tag", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: tagDisponibili.map((tag) {
                final selected = selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedTags.add(tag);
                      } else {
                        selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 🔥 STATO
            const Text("Stato del reperto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: stato,
              items: statiReperto.map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (value) => setState(() => stato = value),
            ),

            const SizedBox(height: 20),

            // 🔥 IMMAGINI
            ElevatedButton.icon(
              onPressed: pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text("Sostituisci immagini"),
            ),

            const SizedBox(height: 10),

            if (immagini.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: immagini.length,
                  itemBuilder: (context, index) {
                    final img = immagini[index];
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(img),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 14,
                          child: GestureDetector(
                            onTap: () => setState(() => immagini.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                //color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            // 🔥 SALVA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveChanges,
                child: const Text("Salva Modifiche"),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 ELIMINA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: deleteItem,
                child: const Text("Elimina Item"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
