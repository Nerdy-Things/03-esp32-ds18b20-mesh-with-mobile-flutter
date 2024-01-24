import 'package:flutter/material.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/ui/page_sensors_list.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nerdy.Things: 03. ESP32 DS18B20 thermometer listener.',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const SensorListPage(),
    );
  }
}
