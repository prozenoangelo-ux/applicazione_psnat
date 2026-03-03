import 'package:flutter/material.dart';
import 'package:applicazione_psnat/detail/edit/newsite.dart';
import 'package:applicazione_psnat/auth/user_manager.dart';
import 'package:applicazione_psnat/auth/login_page.dart';
import 'package:applicazione_psnat/auth/view_users_json_page.dart';
import 'package:applicazione_psnat/detail/view_database_page.dart';

class GlobalMenuButton extends StatelessWidget {
  final void Function(String)? onSelected;

  const GlobalMenuButton({super.key, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),

      onSelected: (value) async {
        // callback esterna se serve
        if (onSelected != null) onSelected!(value);

        if (value == "new_site") {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewSitePage()),
          );
        }

        if (value == "logout") {
          await UserManager.logout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }

        if (value == "view_users_json") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ViewUsersJsonPage()),
          );
        }

        if (value == "view_database") {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ViewDatabasePage()),
  );
}

      },

      itemBuilder: (context) => [
        const PopupMenuItem(value: "settings", child: Text("Impostazioni")),
        const PopupMenuItem(value: "about", child: Text("Informazioni")),
        const PopupMenuItem(value: "help", child: Text("Aiuto")),
        const PopupMenuItem(value: "new_site", child: Text("Nuovo sito")),
        const PopupMenuItem(value: "logout", child: Text("Logout")),
        const PopupMenuItem(value: "view_users_json",child: Text("Mostra users.json"),),
        const PopupMenuItem(value: "view_database",child: Text("Mostra database.json"),),
      ],
    );
  }
}
