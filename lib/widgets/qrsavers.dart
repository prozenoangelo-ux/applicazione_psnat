import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

Future<void> saveQrToGallery(GlobalKey qrKey, String boxId, BuildContext context) async {
  try {
    final boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    const channel = MethodChannel("save_qr_channel");
    final success = await channel.invokeMethod<bool>("saveImage", {
      "bytes": pngBytes,
      "name": boxId,
    });

    if (success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR salvato nella Galleria")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore nel salvataggio")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Errore: $e")),
    );
  }
}
