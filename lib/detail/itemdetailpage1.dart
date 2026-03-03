import 'dart:io';
import 'package:flutter/material.dart';
import 'fullscreen_gallery.dart';
import 'edit/edititempage.dart';
import 'package:applicazione_psnat/detail/database_manager.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Map<String, dynamic> item;

  @override
  void initState() {
    super.initState();
    item = widget.item;
    _reloadItem();
  }

  Future<void> _reloadItem() async {
    await DatabaseManager.load();

    final updated = DatabaseManager.items.firstWhere(
      (i) => i["itemId"] == item["itemId"],
      orElse: () => item,
    );

    setState(() {
      item = Map<String, dynamic>.from(updated);
    });
  }

  // ⭐ Normalizza qualsiasi valore in lista
  Widget _tagField(String label, dynamic value) {
    List<dynamic> list;

    if (value == null) {
      list = [];
    } else if (value is String) {
      list = [value];
    } else if (value is List) {
      list = value;
    } else {
      list = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),

        if (list.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: list.map((v) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  v.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          )
        else
          const Text("Nessun valore",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "N/D";
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> foto = (item["foto"] as List<dynamic>? ?? []);

    final DateTime? createdAt = item["createdAt"] != null
        ? DateTime.tryParse(item["createdAt"])
        : null;

    final DateTime? updatedAt = item["updatedAt"] != null
        ? DateTime.tryParse(item["updatedAt"])
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(item["nome"] ?? "Dettagli Item"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditItemPage(item: Map<String, dynamic>.from(item)),
                ),
              );

              if (!context.mounted) return;

              if (result == "deleted") {
                Navigator.pop(context, "deleted");
                return;
              }

              if (result != null) {
                await _reloadItem();
                Navigator.pop(context, item);
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nome",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _infoBox(item["nome"] ?? ""),

            const SizedBox(height: 24),

            const Text("Descrizione",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _infoBox(item["descrizione"] ?? ""),

            const SizedBox(height: 24),

            _tagField("Materiale", item["materiale"]),
            const SizedBox(height: 24),

            _tagField("Stato del reperto", item["stato"]),
            const SizedBox(height: 24),

            _tagField("Condizioni", item["condizioni"]),
            const SizedBox(height: 24),

            _tagField("Tipologia", item["tipologia"]),
            const SizedBox(height: 24),

            _tagField("Periodo storico", item["periodo"]),
            const SizedBox(height: 24),

            _tagField("Provenienza", item["provenienza"]),
            const SizedBox(height: 24),

            _tagField("Tecnica di produzione", item["tecnica"]),
            const SizedBox(height: 24),

            const Text("Informazioni cronologiche",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            _infoBox(
              "Creato il: ${_formatDate(createdAt)}\n"
              "Ultima modifica: ${_formatDate(updatedAt)}",
            ),

            const SizedBox(height: 30),

            const Text("Immagini",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (foto.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: foto.asMap().entries.map((entry) {
                  final index = entry.key;
                  final path = entry.value;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullscreenGallery(
                            images: foto,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                          image: FileImage(File(path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              const Text("Nessuna immagine disponibile",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
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
      child: Text(
        text,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
