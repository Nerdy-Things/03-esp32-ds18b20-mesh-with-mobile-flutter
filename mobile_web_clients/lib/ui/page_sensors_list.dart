import 'package:flutter/material.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/repository/temperature_sensor_repository.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/ui/page_sensor_item.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/model/temperature_sensor.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/ui/temperature_sensor_name_dialog.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/udp_server.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/ui/page_sensors_button.dart';
import 'package:io.nerdythings.s03.esp32.thermometers/ui/page_sensors_toolbar.dart';

class SensorListPage extends StatefulWidget {
  const SensorListPage({Key? key}) : super(key: key);

  @override
  State<SensorListPage> createState() => _SensorListPageState();
}

class _SensorListPageState extends State<SensorListPage> {
  final UdpServer _server = UdpServer();
  final TemperatureSensorRepository _repository = TemperatureSensorRepository();
  final TemperatureSensorNameDialog dialog = TemperatureSensorNameDialog();

  @override
  void initState() {
    super.initState();
    _server.start();
    _server.sendUpdateRequest();
  }

  Widget temperatureSensorItem(TemperatureSensor sensor) {
    return GestureDetector(
      onTap: () {
        // Handle the tap here
        dialog.showInputAlert(context, sensor.deviceMac);
      },
      child: PageSensorItem(
        id: sensor.deviceMac,
        name: sensor.deviceName,
        temperature: sensor.temperature.toStringAsFixed(2),
        outdated: !sensor.isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageSensorsToolbar(),
      body: Center(
        child: StreamBuilder<List<TemperatureSensor>>(
          stream: _repository.stream,
          builder: (context, snapshot) {
            var sensors = snapshot.data;
            if (snapshot.hasData && sensors != null && sensors.isNotEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _server.sendUpdateRequest();
                      },
                      child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: sensors.length,
                          itemBuilder: (BuildContext context, int index) {
                            return temperatureSensorItem(sensors[index]);
                          }),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    _server.sendUpdateRequest();
                  },
                  child: const Text('No devices found. Update?'),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: const PageSensorsButton(),
    );
  }
}
