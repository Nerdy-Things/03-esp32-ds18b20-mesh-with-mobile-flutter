import 'dart:math';

import 'package:flutter/material.dart';

class PageSensorItem extends StatelessWidget {
  final String id;
  final String? name;
  final String temperature;
  final bool outdated;

  const PageSensorItem(
      {super.key,
      required this.id,
      required this.name,
      required this.temperature,
      required this.outdated});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (outdated) {
      color = Colors.grey.withOpacity(0.5);
    } else {
      color = Colors.transparent;
    }

    String getIdEnding() {
      int start = max(0, id.length - 4);
      return id.substring(start, id.length);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        children: [
          // Background container with gray overlay
          Container(
            width: double.infinity,
            height: 60.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          // Row with Name and Temperature
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    name ?? "${getIdEnding()} (Tap to rename)",
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              // Temperature value (25% of the row)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(2, 16.0, 2, 16.0),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '$temperature °C',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Disabled label
          if (outdated)
            Positioned(
              top: 4.0,
              left: 2.0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Outdated (Pull to refresh)',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
