import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';

class EditBoxPage extends StatefulWidget {
  final Map<String, dynamic> box;

  const EditBoxPage({super.key, required this.box});

  @override
  State<EditBoxPage> createState() => _EditBoxPageState();
}

class _EditBoxPageState extends State<EditBoxPage> {
  late TextEditingController descrizioneController;
  late List<File> immagini;

  String? stato;

  @override
  void initState() {
    super.initState();

    descrizioneController =
        TextEditingController(text: widget.box["descrizione"]);

    immagini = (widget.box["foto"] as List<dynamic>? ?? [])
        .map((path) => File(path))
        .toList();

    stato = widget.box["stato"] ?? "In lavorazione";
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
    widget.box["descrizione"] = descrizioneController.text.trim();
    widget.box["foto"] = immagini.map((f) => f.path).toList();
    widget.box["stato"] = stato;

    // 🔥 aggiorna la data di ultima modifica
    widget.box["updatedAt"] = DateTime.now().toIso8601String();

    final file = await _localFile();
    final content = await file.readAsString();
    List<dynamic> data = jsonDecode(content);

    final index = data.indexWhere((b) => b["boxId"] == widget.box["boxId"]);
    if (index != -1) {
      data[index] = widget.box;
    }

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    if (!mounted) return;
    Navigator.pop(context, widget.box);
  }

  Future<void> deleteBox() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminare questa box?"),
          content: const Text("Questa azione eliminerà anche tutti gli item contenuti."),
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

    data.removeWhere((b) => b["boxId"] == widget.box["boxId"]);

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    if (!mounted) return;
    Navigator.pop(context, "deleted");
  }

  @override
  Widget build(BuildContext context) {
    final String boxId = widget.box["boxId"];
    final String createdAt = widget.box["createdAt"] ?? "N/D";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifica Box"),
        actions: const [
          GlobalMenuButton(),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 QR CODE
            const Text("QR Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            Center(
              child: QrImageView(
                data: boxId,
                version: QrVersions.auto,
                size: 160,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                "ID: $boxId",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 DATA CREAZIONE
            Text("Creata il: $createdAt",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),

            // 🔥 TITOLO (NON modificabile)
            const Text("Titolo (non modificabile)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.box["titolo"],
                style: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 DESCRIZIONE
            const Text("Descrizione",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            TextField(
              controller: descrizioneController,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 STATO
            const Text("Stato della box",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: stato,
              items: [
                "In lavorazione",
                "Da catalogare",
                "Completa",
                "Stoccata",
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
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
                onPressed: deleteBox,
                child: const Text("Elimina Box"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
