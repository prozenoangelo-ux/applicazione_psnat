import 'dart:io';
import 'package:flutter/material.dart';
import 'fullscreen_gallery.dart';
import 'edit/edititempage.dart';

class ItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  // ⭐ LISTA DI TAG (materiale, condizioni, periodo)
  Widget _tagField(String label, dynamic value) {
  // Normalizzo il valore in una lista
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
      Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),

      if (list.isNotEmpty)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((v) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        const Text("Nessun valore", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                Navigator.pop(context, result);
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
            // 🔥 NOME
            const Text("Nome", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _infoBox(item["nome"] ?? ""),

            const SizedBox(height: 24),

            // 🔥 DESCRIZIONE
            const Text("Descrizione", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _infoBox(item["descrizione"] ?? ""),

            const SizedBox(height: 24),

            // 🔥 MATERIALI (LISTA)
            _tagField("Materiale", item["materiale"]),

            const SizedBox(height: 24),

            // 🔥 STATO (SINGOLO)
            _tagField("Stato del reperto", item["stato"]),

            const SizedBox(height: 24),

            // 🔥 CONDIZIONI (LISTA)
            _tagField("Condizioni", item["condizioni"]),

            const SizedBox(height: 24),

            // 🔥 TIPOLOGIA (SINGOLO)
            _tagField("Tipologia", item["tipologia"]),

            const SizedBox(height: 24),

            // 🔥 PERIODO (LISTA)
            _tagField("Periodo storico", item["periodo"]),

            const SizedBox(height: 24),

            // 🔥 PROVENIENZA (SINGOLO)
            _tagField("Provenienza", item["provenienza"]),

            const SizedBox(height: 24),

            // 🔥 TECNICA (SINGOLO)
            _tagField("Tecnica di produzione", item["tecnica"]),

            const SizedBox(height: 24),

            // 🔥 DATE
            const Text("Informazioni cronologiche",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            _infoBox(
              "Creato il: ${_formatDate(createdAt)}\n"
              "Ultima modifica: ${_formatDate(updatedAt)}",
            ),

            const SizedBox(height: 30),

            // 🔥 IMMAGINI
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
