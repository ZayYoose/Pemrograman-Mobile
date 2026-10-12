import 'package:flutter/material.dart';

class Kontak {
  final String nama;
  final String nomor;
  final String email;

  const Kontak(this.nama, this.nomor, this.email);
}

const daftarKontak = [
  Kontak(
    'Purbaya Yudhi Sadewa',
    '021-386-5130',
    'kemenkeu@kemenkeu.go.id',
  ),
  Kontak(
    'Destry Damayanti',
    '131',
    'bicara@bi.go.id',
  ),
  Kontak(
    'Suahasil Nazara',
    '021-386-5130',
    'kemenkeu@kemenkeu.go.id',
  ),
  Kontak(
    'Pratikno',
    '021-384-5629',
    'humas@kemenko-pmk.go.id',
  ),
  Kontak(
    'Fadli Zon',
    '021-384-9225',
    'humas@kemenbud.go.id',
  ),
  Kontak(
    'Abdul Mu’ti',
    '021-571-1144',
    'pengaduan@kemdikdasmen.go.id',
  ),
];

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const KontakPage(),
    );
  }
}

class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
      ),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final item = daftarKontak[index];

          return ListTile(
            leading: CircleAvatar(
              child: Text(item.nama[0]),
            ),
            title: Text(item.nama),
            subtitle: Text(item.nomor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(kontak: item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Kontak kontak;

  const DetailPage({super.key, required this.kontak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kontak.nama),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                kontak.nama[0],
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              kontak.nama,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(kontak.nomor),
            Text(kontak.email),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}