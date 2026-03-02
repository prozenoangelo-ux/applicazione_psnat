import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:applicazione_psnat/detail/boxdetailpage.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  List<dynamic> boxes = [];
  List<dynamic> filteredBoxes = [];
  final TextEditingController searchController = TextEditingController();

  String sortMode = "inserimento"; // "inserimento" | "alfabetico"

  // 🔥 Nuovi filtri
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

  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile() async {
    final path = await _localPath();
    return File('$path/database.json');
  }

  Future<void> loadJson() async {
    try {
      final file = await _localFile();
      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      setState(() {
        boxes = decoded;
        filteredBoxes = decoded;
        applyFilters();
      });
    } catch (e) {
      setState(() {
        boxes = [];
        filteredBoxes = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  void applyFilters() {
    final q = searchController.text.toLowerCase();

    filteredBoxes = boxes.where((box) {
      final titolo = (box["titolo"] ?? "").toLowerCase();
      final descrizione = (box["descrizione"] ?? "").toLowerCase();
      final id = (box["boxId"] ?? "").toLowerCase();

      final matchSearch =
          titolo.contains(q) || descrizione.contains(q) || id.contains(q);

      // 🔥 Filtra per TAG (se selezionato)
      bool matchTag = true;
      if (selectedTag != null) {
        matchTag = false;

        final items = (box["items"] as List<dynamic>? ?? []);
        for (var item in items) {
          final tags = (item["tags"] as List<dynamic>? ?? []).cast<String>();
          if (tags.contains(selectedTag)) {
            matchTag = true;
            break;
          }
        }
      }

      // 🔥 Filtra per STATO (se selezionato)
      bool matchStato = true;
      if (selectedStato != null) {
        matchStato = false;

        final items = (box["items"] as List<dynamic>? ?? []);
        for (var item in items) {
          if (item["stato"] == selectedStato) {
            matchStato = true;
            break;
          }
        }
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
          // 🔍 BARRA DI RICERCA + ORDINAMENTO
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
                    DropdownMenuItem(value: "alfabetico", child: Text("A → Z")),
                  ],
                  onChanged: (value) {
                    sortMode = value!;
                    setState(() => applyFilters());
                  },
                ),
              ],
            ),
          ),

          // 🔥 FILTRI TAG + STATO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // TAG
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

                // STATO
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

          // LISTA RISULTATI
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
                            await loadJson();
                            setState(() {});
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
                              // 🔥 ANTEPRIMA: foto del primo item, oppure QR
                              _buildPreview(box),

                              const SizedBox(width: 16),

                              // 🔥 TESTO
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
    final items = (box["items"] as List<dynamic>? ?? []);

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

    Widget _buildPreview(Map<String, dynamic> box) {
      final items = (box["items"] as List<dynamic>? ?? []);

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

    _buildPreview(box);
    // 🔥 Altrimenti mostra il QR della box
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
