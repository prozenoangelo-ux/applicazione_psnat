import 'package:flutter/material.dart';

class GlobalMenuButton extends StatelessWidget {
  final void Function(String)? onSelected;

  const GlobalMenuButton({super.key, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: "settings",
          child: Text("Impostazioni"),
        ),
        const PopupMenuItem(
          value: "about",
          child: Text("Informazioni"),
        ),
        const PopupMenuItem(
          value: "help",
          child: Text("Aiuto"),
        ),
      ],
    );
  }
}
