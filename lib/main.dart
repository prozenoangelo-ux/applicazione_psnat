import 'package:flutter/material.dart';
import 'home/scanpage.dart';
import 'home/newpage.dart';
import 'home/searchpage.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';

void main() {
  runApp(const MyApp());
}

class CentralButtonsWidget extends StatelessWidget {
  const CentralButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // 🔥 Riconoscimento tablet vs telefono
        final bool isTablet = w > h; // schermo largo → tablet

        // 🔥 Numero colonne e righe
        final int columns = isTablet ? 2 : 1;
        final int rows = isTablet ? 2 : 3;

        // 🔥 Dimensioni proporzionali del contenitore
        final containerWidth = w * 0.90;
        final containerHeight = h * 0.90;

        final padding = w * 0.04;
        final borderRadius = w * 0.06;
        final borderWidth = w * 0.004;

        // 🔥 Calcolo dimensione massima dei pulsanti
        final double maxButtonWidth = (containerWidth - padding * 2) / columns;
        final double maxButtonHeight = (containerHeight - padding * 2) / rows;

        // 🔥 Pulsante quadrato che non sfora mai
        final double buttonSize = maxButtonWidth < maxButtonHeight
            ? maxButtonWidth
            : maxButtonHeight;

        return Center(
          child: Container(
            width: containerWidth,
            height: containerHeight,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.grey.shade400, width: borderWidth),
            ),

            child: GridView.count(
              crossAxisCount: columns,
              mainAxisSpacing: padding,
              crossAxisSpacing: padding,
              childAspectRatio: 1, // pulsanti quadrati
              children: [
                _buildButton(
                  context,
                  size: buttonSize,
                  icon: Icons.qr_code_scanner,
                  label: "Scansiona",
                  page: const ScanPage(),
                ),
                _buildButton(
                  context,
                  size: buttonSize,
                  icon: Icons.search,
                  label: "Search",
                  page: const Searchpage(),
                ),
                _buildButton(
                  context,
                  size: buttonSize,
                  icon: Icons.add_box,
                  label: "New QR",
                  page: const NewBoxPage(),
                ),

                // 🔥 Quarto slot solo su tablet (2×2)
                if (isTablet)
                  Center(
                    child: Text(
                      "BoxApp",
                      style: TextStyle(
                        fontSize: buttonSize * 0.15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required double size,
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size * 0.15),
          ),
          padding: EdgeInsets.all(size * 0.10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: size * 0.30),
            SizedBox(height: size * 0.05),
            Text(label, style: TextStyle(fontSize: size * 0.12)),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoxApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 40, 94, 50),
        ),
      ),
      home: const MyHomePage(title: 'BoxApp'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(title),
        actions: const [
          GlobalMenuButton(),
        ],
      ),
      body: const CentralButtonsWidget(),
    );
  }
}
