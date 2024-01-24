import 'package:flutter/material.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/repository/temperature_sensor_repository.dart';

class TemperatureSensorNameDialog {
  final TemperatureSensorRepository _repository = TemperatureSensorRepository();
  // Function to show the input alert
  void showInputAlert(BuildContext context, String deviceId) {
    String inputValue = ''; // Variable to store the user input

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Sensor\'s Name'),
          content: TextField(
            onChanged: (value) {
              inputValue = value; // Update the input value as the user types
            },
            decoration: const InputDecoration(
              hintText: 'Enter new name...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _repository.setSensorName(deviceId, inputValue);
                Navigator.of(context).pop(); // Close the alert
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}