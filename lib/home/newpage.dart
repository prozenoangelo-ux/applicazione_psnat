import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';
import 'package:applicazione_psnat/widgets/qrsavers.dart';
import 'package:applicazione_psnat/detail/database_manager.dart';

final GlobalKey qrKey = GlobalKey();

class NewBoxPage extends StatefulWidget {
  const NewBoxPage({super.key});

  @override
  State<NewBoxPage> createState() => _NewBoxPageState();
}

class _NewBoxPageState extends State<NewBoxPage> {
  final titoloController = TextEditingController();
  final descrizioneController = TextEditingController();

  DateTime createdAt = DateTime.now();
  String? stato;

  String boxId = "";

  final List<String> statiBox = [
    "In lavorazione",
    "Da catalogare",
    "Completa",
    "Stoccata",
  ];

  @override
  void initState() {
    super.initState();
    stato = statiBox.first;
  }

  void _updateBoxId() {
    final titolo = titoloController.text.trim().toLowerCase();

    if (titolo.isEmpty) {
      setState(() => boxId = "");
      return;
    }

    final safeTitle = titolo.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    boxId = "${safeTitle}_${DateTime.now().millisecondsSinceEpoch}";
    setState(() {});
  }

  Future<void> saveBox() async {
    final titolo = titoloController.text.trim();
    final descrizione = descrizioneController.text.trim();

    if (titolo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Il titolo non può essere vuoto"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (boxId.isEmpty) {
      _updateBoxId();
    }

    final newBox = {
      "boxId": boxId,
      "titolo": titolo,
      "descrizione": descrizione,
      "foto": [],
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": createdAt.toIso8601String(),
      "stato": stato,
    };

    await DatabaseManager.addBox(newBox);

    if (!mounted) return;
    Navigator.pop(context, newBox);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuova Box"),
        actions: const [GlobalMenuButton()],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Data creazione: $createdAt"),
            const SizedBox(height: 20),

            Center(
              child: boxId.isEmpty
                  ? const SizedBox() // Nessun QR se non c’è titolo
                  : Column(
                      children: [
                        GestureDetector(
                          onTap: () => saveQrToGallery(qrKey, boxId, context),
                          child: RepaintBoundary(
                            key: qrKey,
                            child: QrImageView(
                              data: boxId,
                              version: QrVersions.auto,
                              size: 180,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "ID: $boxId",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Titolo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: titoloController,
              onChanged: (_) => _updateBoxId(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Inserisci il titolo della box",
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

            const Text(
              "Stato della box",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: stato,
              items: statiBox.map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (value) => setState(() => stato = value),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveBox,
                child: const Text("Crea Box"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
