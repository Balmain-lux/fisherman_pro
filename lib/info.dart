import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("О приложении")),
      body: Column(
        children: [
          Text("dfpofdopdfopfdpopofdpof"),
          Text("dfpofdopdfopfdpopofdpof"),
          Text("dfpofdopdfopfdpopofdpof"),
          Text("dfpofdopdfopfdpopofdpof"),
        ],
      ),
      bottomNavigationBar: ListTile(
        leading: Icon(Icons.person),
        title: InkWell(
          child: Text("ссылка на тг"),
          onTap: () {
            launchUrl(Uri.parse("https://pub.dev/packages?q=uri_launcher"));
          },
        ),
        subtitle: Text('Разработчик'),
      ),
    );
  }
}
