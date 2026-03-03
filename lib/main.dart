import 'package:flutter/material.dart';
import 'package:applicazione_psnat/auth/user_manager.dart';
import 'package:applicazione_psnat/auth/login_page.dart';
import 'package:applicazione_psnat/home/hompage.dart';
import 'package:applicazione_psnat/detail/database_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseManager.load();

  // 🔥 Carica il file users.json
  await UserManager.load();

  // 🔥 Controlla se c'è un utente loggato
  final user = UserManager.currentUser();

  runApp(MyApp(
    startPage: user == null
        ? const LoginPage()                       // Nessun utente → Login
        : const MyHomePage(title: "BoxApp"),       // Utente loggato → Home
  ));
}

class MyApp extends StatelessWidget {
  final Widget startPage;

  const MyApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoxApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 40, 94, 50),
        ),
      ),
      home: startPage, // 🔥 pagina iniziale dinamica
    );
  }
}
