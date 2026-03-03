import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:applicazione_psnat/detail/boxdetailpage.dart';
import 'package:applicazione_psnat/detail/database_manager.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? controller;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    DatabaseManager.load(); // 🔥 assicura che il DB sia pronto
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller!.initialize();
    if (mounted) setState(() {});
  }

  // 🔥 Cerca la box nel DatabaseManager
  Map<String, dynamic>? _findBoxById(String id) {
    try {
      return DatabaseManager.boxes.firstWhere(
        (b) => b["boxId"] == id,
        orElse: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final barcode = capture.barcodes.first;
    final String? rawValue = barcode.rawValue;
    if (rawValue == null) return;

    isProcessing = true;

    final box = _findBoxById(rawValue);

    if (box == null) {
      isProcessing = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR non valido o box non trovata"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailBoxPage(box: box)),
    ).then((_) {
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 🔥 Anteprima fotocamera
          CameraPreview(controller!),

          // 🔥 Scanner QR
          MobileScanner(
            onDetect: _onDetect,
            fit: BoxFit.cover,
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
