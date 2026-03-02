import 'dart:io';
import 'package:flutter/material.dart';
import 'edit/newitempage.dart';
import 'itemdetailpage1.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';
import 'package:applicazione_psnat/detail/edit/editboxpage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:applicazione_psnat/widgets/qrsavers.dart';

class DetailBoxPage extends StatefulWidget {
  final Map<String, dynamic> box;

  const DetailBoxPage({super.key, required this.box});

  @override
  State<DetailBoxPage> createState() => _DetailBoxPageState();
}

class _DetailBoxPageState extends State<DetailBoxPage> {
  late Map<String, dynamic> box;

  final GlobalKey qrKey = GlobalKey();   // 🔥 KEY PER SALVARE IL QR

  @override
  void initState() {
    super.initState();
    box = widget.box;
  }

  String _formatDate(String? iso) {
    if (iso == null) return "N/D";
    final dt = DateTime.tryParse(iso);
    if (dt == null) return "N/D";

    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  List<String> _collectTags() {
    final items = (box["items"] as List<dynamic>? ?? []);
    final Set<String> tags = {};

    for (var it in items) {
      final t = (it["tags"] as List<dynamic>? ?? []).cast<String>();
      tags.addAll(t);
    }

    return tags.toList();
  }

  List<String> _collectStates() {
    final items = (box["items"] as List<dynamic>? ?? []);
    final Set<String> stati = {};

    for (var it in items) {
      if (it["stato"] != null) stati.add(it["stato"]);
    }

    return stati.toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = (box["items"] as List<dynamic>? ?? []);
    final tags = _collectTags();
    final stati = _collectStates();

    final createdAt = _formatDate(box["createdAt"]);
    final updatedAt = _formatDate(box["updatedAt"]);

    return Scaffold(
      appBar: AppBar(
        title: Text(box["titolo"] ?? "Dettagli Box"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditBoxPage(box: box)),
              );

              if (result == "deleted") {
                Navigator.pop(context, "deleted");
                return;
              }

              if (result != null) {
                setState(() {
                  box = result;
                });
              }
            },
          ),
          const GlobalMenuButton(),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedBox = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewItemPage(box: box)),
          );

          if (updatedBox != null) {
            setState(() {
              box = updatedBox;
            });
          }
        },
        child: const Icon(Icons.add),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 QR CODE CLICCABILE + ID
            Center(
              child: GestureDetector(
                onTap: () => saveQrToGallery(qrKey, box["boxId"], context),
                child: RepaintBoundary(
                  key: qrKey,
                  child: QrImageView(
                    data: box["boxId"] ?? "",
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                "ID: ${box["boxId"]}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 24),

            const Text("Titolo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _infoBox(box["titolo"] ?? ""),

            const SizedBox(height: 24),

            const Text("Descrizione",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _infoBox(box["descrizione"] ?? ""),

            const SizedBox(height: 24),

            const Text("Informazioni cronologiche",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            _infoBox(
              "Creata il: $createdAt\n"
              "Ultima modifica: $updatedAt",
            ),

            const SizedBox(height: 24),

            const Text("Informazioni Box",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            _infoBox(
              "Numero di item: ${items.length}\n"
              "Tag presenti: ${tags.isEmpty ? "Nessuno" : tags.join(", ")}\n"
              "Stati presenti: ${stati.isEmpty ? "Nessuno" : stati.join(", ")}",
            ),

            const SizedBox(height: 30),

            const Text("Items nella Box",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (items.isEmpty)
              const Text("Nessun item presente",
                  style: TextStyle(fontSize: 16, color: Colors.grey))
            else
              Column(
                children: items.map((it) {
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(item: it),
                        ),
                      );

                      if (result == "deleted") {
                        setState(() {
                          box["items"].removeWhere(
                              (x) => x["itemId"] == it["itemId"]);
                        });
                        return;
                      }

                      if (result != null) {
                        setState(() {
                          final index = box["items"].indexWhere(
                              (x) => x["itemId"] == result["itemId"]);
                          if (index != -1) {
                            box["items"][index] = result;
                          }
                        });
                      }
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(blurRadius: 6, offset: const Offset(0, 3)),
                        ],
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade200,
                              image: (it["foto"] != null &&
                                      it["foto"] is List &&
                                      it["foto"].isNotEmpty)
                                  ? DecorationImage(
                                      image: FileImage(File(it["foto"][0])),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (it["foto"] == null || it["foto"].isEmpty)
                                ? const Icon(Icons.image, color: Colors.grey)
                                : null,
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it["nome"] ?? "Senza nome",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(it["descrizione"] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}