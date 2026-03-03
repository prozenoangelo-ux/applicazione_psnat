import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:applicazione_psnat/detail/boxdetailpage.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';
import 'package:applicazione_psnat/detail/database_manager.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  List<Map<String, dynamic>> boxes = [];
  List<Map<String, dynamic>> filteredBoxes = [];

  final TextEditingController searchController = TextEditingController();

  String sortMode = "inserimento";

  String? selectedTag;
  String? selectedStato;

  final List<String> tagDisponibili = [
    "ceramica",
    "metallo",
    "legno",
    "vetro",
    "tessuto",
    "fragile",
    "restauro",
    "catalogato",
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
    _loadData();
  }

  Future<void> _loadData() async {
    await DatabaseManager.load();

    boxes = DatabaseManager.boxes
        .map((b) => Map<String, dynamic>.from(b))
        .toList();

    filteredBoxes = List.from(boxes);

    applyFilters();
  }

  void applyFilters() {
    final q = searchController.text.toLowerCase();

    filteredBoxes = boxes.where((box) {
      final titolo = (box["titolo"] ?? "").toLowerCase();
      final descrizione = (box["descrizione"] ?? "").toLowerCase();
      final id = (box["boxId"] ?? "").toLowerCase();

      final matchSearch =
          titolo.contains(q) || descrizione.contains(q) || id.contains(q);

      final items = DatabaseManager.items
          .where((i) => i["boxId"] == box["boxId"])
          .toList();

      bool matchTag = true;
      if (selectedTag != null) {
        matchTag = items.any((item) {
          final tags = (item["tags"] as List<dynamic>? ?? []).cast<String>();
          return tags.contains(selectedTag);
        });
      }

      bool matchStato = true;
      if (selectedStato != null) {
        matchStato = items.any((item) => item["stato"] == selectedStato);
      }

      return matchSearch && matchTag && matchStato;
    }).toList();

    applySorting();
  }

  void applySorting() {
    if (sortMode == "alfabetico") {
      filteredBoxes.sort(
        (a, b) => (a["titolo"] ?? "").toString().compareTo(
              (b["titolo"] ?? "").toString(),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archivio Box"),
        actions: const [GlobalMenuButton()],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() => applyFilters()),
                    decoration: InputDecoration(
                      hintText: "Cerca per titolo, descrizione o ID...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                DropdownButton<String>(
                  value: sortMode,
                  items: const [
                    DropdownMenuItem(
                      value: "inserimento",
                      child: Text("Inserimento"),
                    ),
                    DropdownMenuItem(
                      value: "alfabetico",
                      child: Text("A → Z"),
                    ),
                  ],
                  onChanged: (value) {
                    sortMode = value!;
                    setState(() => applyFilters());
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Filtra per tag"),
                    value: selectedTag,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("Tutti i tag"),
                      ),
                      ...tagDisponibili.map(
                        (t) => DropdownMenuItem(value: t, child: Text(t)),
                      ),
                    ],
                    onChanged: (value) {
                      selectedTag = value;
                      setState(() => applyFilters());
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Filtra per stato"),
                    value: selectedStato,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("Tutti gli stati"),
                      ),
                      ...statiReperto.map(
                        (s) => DropdownMenuItem(value: s, child: Text(s)),
                      ),
                    ],
                    onChanged: (value) {
                      selectedStato = value;
                      setState(() => applyFilters());
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filteredBoxes.isEmpty
                ? const Center(
                    child: Text(
                      "Nessuna box trovata",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBoxes.length,
                    itemBuilder: (context, index) {
                      final box = filteredBoxes[index];

                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailBoxPage(box: box),
                            ),
                          );

                          if (result == "deleted") {
                            await _loadData();
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
                              BoxShadow(
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPreview(box),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      box["titolo"] ?? "Senza titolo",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "ID: ${box["boxId"]}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      box["descrizione"] ?? "",
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(Map<String, dynamic> box) {
    final items = DatabaseManager.items
        .where((i) => i["boxId"] == box["boxId"])
        .toList();

    if (items.isNotEmpty) {
      final firstItem = items.first;
      final foto = (firstItem["foto"] as List<dynamic>? ?? []);

      if (foto.isNotEmpty) {
        final path = foto.first;

        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
            image: DecorationImage(
              image: FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: QrImageView(
        data: box["boxId"] ?? "",
        version: QrVersions.auto,
        backgroundColor: Colors.white,
      ),
    );
  }
}
