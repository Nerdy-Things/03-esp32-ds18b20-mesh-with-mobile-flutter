class TemperatureSensor {
  String deviceMac;
  String? deviceName;
  double temperature;
  DateTime created = DateTime.now();
  bool isActive = true;

  TemperatureSensor({
    required this.deviceMac,
    required this.deviceName,
    required this.temperature,
  });

  factory TemperatureSensor.fromJson(
      Map<String, dynamic> json,
      String? deviceName,
    ) {
    double temperature = 0;
    try {
      temperature = double.parse(json['temperature']);
    } catch (e) {
      print('Error parsing string to double: $e');
    }
    return TemperatureSensor(
      deviceMac: json['mac_address'] ?? "unknown",
      deviceName: deviceName,
      temperature: temperature,
    );
  }
}
