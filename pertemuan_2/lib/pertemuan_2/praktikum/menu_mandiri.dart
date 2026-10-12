import 'package:flutter/material.dart';

class Makanan {
  final String nama;
  final int harga;
  final String deskripsi;

  const Makanan(this.nama, this.harga, this.deskripsi);
}

const daftarMenu = [
  Makanan('Nasi Goreng', 15000, 'Nasi goreng dengan bumbu khas.'),
  Makanan('Mie Ayam', 12000, 'Mie dengan ayam dan kuah gurih.'),
  Makanan('Es Teh', 4000, 'Teh dingin yang menyegarkan.'),
  Makanan('Ayam Bakar', 20000, 'Ayam bakar dengan bumbu khas.'),
  Makanan('Bubur', 10000, 'Bubur ayam dengan topping lengkap.'),
  Makanan('Nasi Uduk', 12000, 'Nasi uduk dengan lauk pendamping.'),
  Makanan('Teh Anget', 2000, 'Teh hangat yang manis dan menyegarkan.'),
];

String formatHarga(int harga) {
  return '${harga ~/ 1000}.000';
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 2',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
      ),
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(item.nama),
              subtitle: Text('Rp ${formatHarga(item.harga)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(makanan: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Makanan makanan;

  const DetailPage({super.key, required this.makanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(makanan.nama),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              makanan.nama,
              style: const TextStyle(fontSize: 24),
            ),
            Text('Rp ${formatHarga(makanan.harga)}'),
            Text(makanan.deskripsi),
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