import 'package:flutter/material.dart';

class PageSensorsToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  const PageSensorsToolbar({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(100.0); // Adjust the height as needed

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100.0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nerdy.Things',
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              )),
          Text('ESP32 Thermometers mesh',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              )),
        ],
      ),
      backgroundColor: Colors.black87,
    );
  }
}
