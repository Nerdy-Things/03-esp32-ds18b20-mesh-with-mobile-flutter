import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PageSensorsButton extends StatelessWidget {
  const PageSensorsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _floatingButton();
  }

  Widget _floatingButton() {
    return FloatingActionButton(
      backgroundColor: Colors.white.withAlpha(0),
      elevation: 0,
      heroTag: "floatingActionBtn",
      child: Image.asset("assets/images/nerdy_things_channel.png"),
      onPressed: () => _openYoutube(),
    );
  }

  void _openYoutube() async {
    var url = Uri.parse('https://www.youtube.com/@Nerdy.Things');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
