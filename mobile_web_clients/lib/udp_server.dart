import 'dart:io';
import 'dart:convert';

import 'package:io.nerdythings.s03.esp32.thermometers/repository/temperature_sensor_repository.dart';

class UdpServer {
  static const _portToReceive = 54678;
  static const _portToRequest = 54679;
  static const _messageToUpdate = "update";
  final TemperatureSensorRepository _repository = TemperatureSensorRepository();

  void start() {
    // listen forever & send response
    RawDatagramSocket.bind(InternetAddress.anyIPv4, _portToReceive)
        .then((socket) {
      socket.listen(
        (RawSocketEvent event) {
          print("EVENT = $event");
          if (event == RawSocketEvent.read) {
            Datagram? dg = socket.receive();
            if (dg == null) return;
            final receivedMessage = String.fromCharCodes(dg.data);
            if (receivedMessage == "ping") {
              socket.send(
                  const Utf8Codec().encode("pong"), dg.address, _portToReceive);
            }
            _repository.messageReceived(
              dg.address.address,
              dg.port,
              receivedMessage,
            );
          }
        },
        onError: (error) {
          print('UdpError: $error');
        },
        onDone: () {
          print('UdpSocket is closed');
        },
      );
      print("udp listening on $_portToReceive");
    });
  }

  void sendUpdateRequest() async {
    var ip = await getIpAddress();
    if (ip == null) {
      print("IP IS NULL");
      return;
    }
    var broadcastIP = replaceLastNumbersWith255(ip);
    if (broadcastIP == null) {
      print("broadcastIP IS NULL");
      return;
    }
    var broadcastIA = InternetAddress(
      broadcastIP,
      type: InternetAddressType.IPv4,
    );
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
      print(
          "Sending $_messageToUpdate broadcast to $broadcastIA:$_portToRequest");
      socket.broadcastEnabled = true;
      socket.send(_messageToUpdate.codeUnits, broadcastIA, _portToRequest);
      socket.close();
    }).catchError((error) {
      print("Error: $error");
    });
  }

  String? replaceLastNumbersWith255(String ipAddress) {
    List<String> octets = ipAddress.split('.');
    if (octets.length >= 4) {
      octets[3] = '255';
      return octets.join('.');
    } else {
      return null;
    }
  }

  Future<String?> getIpAddress() async {
    try {
      var interfaces =
          await NetworkInterface.list(type: InternetAddressType.IPv4);
      // Search for en
      for (NetworkInterface interface in interfaces) {
        print(interface.name);
        if (interface.name.startsWith("en") ||
            interface.name.startsWith("wlan")) {
          for (InternetAddress address in interface.addresses) {
            if (address.type == InternetAddressType.IPv4 &&
                !address.isLoopback) {
              return address.address;
            }
          }
        }
      }
      // Search for any
      for (NetworkInterface interface in interfaces) {
        for (InternetAddress address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            return address.address;
          }
        }
      }
    } catch (e) {
      print('Error getting Wi-Fi IP address: $e');
    }
    return null;
  }
}
