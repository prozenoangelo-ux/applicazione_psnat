import 'package:flutter/material.dart';
import 'scanpage.dart';
import 'searchpage.dart';
import 'package:applicazione_psnat/home/newpage.dart';
import 'package:applicazione_psnat/widgets/global_menu_button.dart';
import 'package:applicazione_psnat/home/syncpage.dart';

class CentralButtonsWidget extends StatelessWidget {
  const CentralButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      //  GlobalMenuButton anche qui
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          GlobalMenuButton(),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          final bool isTablet = w > h;
          final int columns = isTablet ? 2 : 1;
          final int rows = isTablet ? 2 : 3;

          final containerWidth = w * 0.90;
          final containerHeight = h * 0.90;

          final padding = w * 0.04;
          final borderRadius = w * 0.06;
          final borderWidth = w * 0.004;

          final double maxButtonWidth = (containerWidth - padding * 2) / columns;
          final double maxButtonHeight = (containerHeight - padding * 2) / rows;

          final double buttonSize =
              maxButtonWidth < maxButtonHeight ? maxButtonWidth : maxButtonHeight;

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
                childAspectRatio: 1,
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
                    label: "New Box",
                    page: const NewBoxPage(),
                  ),
                  _buildButton(
                    context,
                    size: buttonSize,
                    icon: Icons.sync,
                    label: "Sync Page",
                    page: const SyncPage(),
                  ),


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
      ),
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
