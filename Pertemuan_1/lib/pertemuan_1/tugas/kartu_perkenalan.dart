import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kartu Perkenalan',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kartu Perkenalan'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.person,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Teguh Tegar Aulia',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 10),
              Text('NIM: 20230801124'),
              SizedBox(height: 10),
              Text('Jurusan: Teknik Informatika'),
              SizedBox(height: 10),
              Text('Hobi: Bermain Game'),
            ],
          ),
        ),
      ),
    );
  }
}