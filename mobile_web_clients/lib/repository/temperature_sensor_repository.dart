import 'dart:async';
import 'dart:convert';

import 'package:io.nerdythings.s03.esp32.thermometers/model/temperature_sensor.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/repository/preference_repository.dart';
import 'package:synchronized/synchronized.dart';

class TemperatureSensorRepository {
  static const sensorTimeout = 60;

  // Private constructor
  TemperatureSensorRepository._privateConstructor() {
    Timer.periodic(const Duration(seconds: sensorTimeout), (timer) {
      checkIfDevicesActive();
    });
  }

  // Static instance of the class
  static final TemperatureSensorRepository _instance =
      TemperatureSensorRepository._privateConstructor();
  static final PreferenceRepository preferences = PreferenceRepository();

  // Getter to access the instance
  factory TemperatureSensorRepository() {
    return _instance;
  }

  final lock = Lock(reentrant: true);

  final sensorsMap = <String, TemperatureSensor>{};
  final StreamController<List<TemperatureSensor>> _sensorsController =
      StreamController<List<TemperatureSensor>>();

  Stream<List<TemperatureSensor>> get stream => _sensorsController.stream;

  void messageReceived(String address, int port, String receivedMessage) async {
    print("Received: $receivedMessage");
    Map<String, dynamic> jsonData = json.decode(receivedMessage);
    var deviceName = await preferences.loadData(
      PreferenceKey.deviceId,
      jsonData["mac_address"],
    );
    var sensor = TemperatureSensor.fromJson(jsonData, deviceName);
    lock.synchronized(() {
      var stored = sensorsMap[sensor.deviceMac];
      if (stored != null) {
        stored.isActive = true;
        stored.temperature = sensor.temperature;
        stored.created = DateTime.now();
      } else {
        sensorsMap[sensor.deviceMac] = sensor;
      }
      _updateList();
    });
  }

  void checkIfDevicesActive() {
    lock.synchronized(() {
      DateTime threshold = DateTime.now().subtract(const Duration(seconds: sensorTimeout));
      for (var element in sensorsMap.entries) {
        if (element.value.created.isBefore(threshold)) {
          element.value.isActive = false;
        }
      }
      _updateList();
    });
  }

  void _updateList() {
    var sensorList = sensorsMap.entries.map((e) => e.value).toList();
    // Sort the list using a custom comparison function
    sensorList.sort((a, b) {
      // Check if deviceName is null or empty
      bool aNameEmpty = a.deviceName == null || a.deviceName!.isEmpty;
      bool bNameEmpty = b.deviceName == null || b.deviceName!.isEmpty;

      // Compare based on deviceName or deviceMac if name is empty
      if (!aNameEmpty && !bNameEmpty) {
        return a.deviceName!.compareTo(b.deviceName!);
      } else if (!aNameEmpty) {
        return -1; // a should come first if only b has an empty name
      } else if (!bNameEmpty) {
        return 1; // b should come first if only a has an empty name
      } else {
        return a.deviceMac.compareTo(b.deviceMac);
      }
    });
    _sensorsController.add(sensorList);
  }

  void setSensorName(String sensorId, String inputValue) async {
    lock.synchronized(() {
      preferences.saveData(PreferenceKey.deviceId, sensorId, inputValue);
      sensorsMap[sensorId]?.deviceName = inputValue;
      _updateList();
    });
  }
}
