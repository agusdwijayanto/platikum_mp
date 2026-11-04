import 'package:flutter/material.dart';

class P3ListView extends StatelessWidget {
  const P3ListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertemuan 3 - Basic List'),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.access_alarm),
              title: Text('Alarm'),
            ),
          ),
          ListTile(leading: Icon(Icons.phone), title: Text('Phone')),
          ListTile(leading: Icon(Icons.camera), title: Text('Camera')),
          ListTile(leading: Icon(Icons.message), title: Text('Message')),
        ],
      ),
    );
  }
}
