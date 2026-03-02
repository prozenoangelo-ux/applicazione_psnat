import 'dart:io';
import 'package:flutter/material.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';

class FullscreenGallery extends StatefulWidget {
  final List<dynamic> images;
  final int initialIndex;

  const FullscreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          GlobalMenuButton(
            onSelected: (value) {
              switch (value) {
                case "settings":
                  // Naviga alla pagina impostazioni
                  break;
                case "about":
                  // Mostra info app
                  break;
                case "help":
                  // Apri guida
                  break;
              }
            },
          ),
        ],
      ),

      body: PageView.builder(
        controller: controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final path = widget.images[index];

          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
