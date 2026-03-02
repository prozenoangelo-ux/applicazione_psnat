import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';
import 'package:applicazione_psnat/widgets/multitagselector.dart';
import 'package:applicazione_psnat/widgets/tagselector.dart';

class NewItemPage extends StatefulWidget {
  final Map<String, dynamic> box;

  const NewItemPage({super.key, required this.box});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final nomeController = TextEditingController();
  final descrizioneController = TextEditingController();
  List<File> immagini = [];

  DateTime createdAt = DateTime.now();

  // 🔥 Nuove categorie
  List<String> materiale=[];
  String? stato;
  List<String> condizioni = [];
  String? tipologia;
  List<String> periodo=[];
  String? provenienza;
  String? tecnica;

  // 🔥 Liste valori
  final List<String> materiali = [
    "Ceramica",
    "Terracotta",
    "Metallo",
    "Bronzo",
    "Ferro",
    "Piombo",
    "Oro",
    "Argento",
    "Vetro",
    "Pietra",
    "Marmo",
    "Ossa",
    "Legno",
    "Tessuto",
    "Avorio",
  ];

  List<String> statiReperto = [
    "In lavorazione",
    "Da pulire",
    "Da catalogare",
    "Pulito e catalogato",
    "Stoccato",
  ];

  List<String> condizioniReperto = [
    "Ottime",
    "Buone",
    "Discrete",
    "Scarse",
    "Frammentato",
    "Ricostruito",
    "Erosione",
    "Corrosione",
    "Incrinato",
    "Rotto",
    "Completo",
    "Parziale",
  ];

  List<String> tipologie = [
    "Anfora",
    "Vaso",
    "Coppa",
    "Piatto",
    "Lucerna",
    "Statua",
    "Moneta",
    "Fibula",
    "Utensile",
    "Arma",
    "Ornamento",
    "Frammento",
  ];

  List<String> periodi = [
    "Preistorico",
    "Protostorico",
    "Età del Bronzo",
    "Età del Ferro",
    "Periodo Greco",
    "Periodo Romano",
    "Tardoantico",
    "Medievale",
    "Rinascimentale",
  ];

  List<String> provenienze = [
    "Scavo",
    "Superficie",
    "Deposito",
    "Collezione",
    "Rinvenimento casuale",
    "Donazione",
  ];

  List<String> tecniche = [
    "Tornitura",
    "Fusione",
    "Forgiatura",
    "Stampo",
    "Intaglio",
    "Incisione",
    "Decorazione dipinta",
    "Smaltatura",
  ];

  @override
  void initState() {
    super.initState();
    stato = statiReperto.first;
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

  Future<void> saveItem() async {
    final nome = nomeController.text.trim();
    final descrizione = descrizioneController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Il nome non può essere vuoto"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newItem = {
      "itemId": DateTime.now().millisecondsSinceEpoch.toString(),
      "nome": nome,
      "descrizione": descrizione,
      "foto": immagini.map((f) => f.path).toList(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": createdAt.toIso8601String(),

      // 🔥 Nuove categorie salvate nel JSON
      "materiale": materiale,
      "stato": stato,
      "condizioni": condizioni,
      "tipologia": tipologia,
      "periodo": periodo,
      "provenienza": provenienza,
      "tecnica": tecnica,
    };

    widget.box["items"] ??= [];
    widget.box["items"].add(newItem);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuovo Item"),
        actions: const [GlobalMenuButton()],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Data creazione: ${createdAt.toLocal()}"),
            const SizedBox(height: 20),

            const Text(
              "Nome",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Inserisci il nome dell'item",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Descrizione",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: descrizioneController,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Inserisci una descrizione",
              ),
            ),

            const SizedBox(height: 20),




            MultiTagSelector(
              label: "Condizioni",
              options: condizioniReperto,
              selected: condizioni,
              onChanged: (v) => setState(() => condizioni = v),
            ),

            TagSelector(
              label: "Tipologia",
              options: tipologie,
              selected: tipologia,
              onSelected: (v) => setState(() => tipologia = v),
            ),

            MultiTagSelector(
              label: "Periodo storico",
              options: periodi,
              selected: periodo,
              onChanged: (v) => setState(() => periodo = v),
            ),

            TagSelector(
              label: "Provenienza",
              options: provenienze,
              selected: provenienza,
              onSelected: (v) => setState(() => provenienza = v),
            ),

            TagSelector(
              label: "Tecnica di produzione",
              options: tecniche,
              selected: tecnica,
              onSelected: (v) => setState(() => tecnica = v),
            ),

            ElevatedButton.icon(
              onPressed: pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text("Carica immagini"),
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
                            onTap: () =>
                                setState(() => immagini.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveItem,
                child: const Text("Salva Item"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
