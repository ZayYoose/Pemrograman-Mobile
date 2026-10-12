import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Barang {
  String nama, kategori;
  int jumlah;
  bool dibeli;

  Barang(this.nama, this.jumlah, this.kategori, {this.dibeli = false});
}

class BelanjaModel extends ChangeNotifier {
  final List<Barang> _items = [];

  List<Barang> get items => _items;
  int get belumDibeli => _items.where((b) => !b.dibeli).length;

  void tambah(String nama, int jumlah, String kategori) {
    _items.add(Barang(nama, jumlah, kategori));
    notifyListeners();
  }

  void toggle(int i) {
    _items[i].dibeli = !_items[i].dibeli;
    notifyListeners();
  }

  void hapus(int i) {
    _items.removeAt(i);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BelanjaModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Belanja',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const BelanjaPage(),
    );
  }
}

class BelanjaPage extends StatelessWidget {
  const BelanjaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BelanjaModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Belanja (${model.belumDibeli})'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: model.items.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada barang',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: model.items.length,
        itemBuilder: (context, i) {
          final b = model.items[i];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  Icons.shopping_bag,
                  color: Colors.blue,
                ),
              ),
              title: Text(
                b.nama,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: b.dibeli
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(
                '${b.jumlah} • ${b.kategori}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: b.dibeli,
                    onChanged: (_) => model.toggle(i),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => model.hapus(i),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahPage(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TambahPage extends StatefulWidget {
  const TambahPage({super.key});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _jumlah = TextEditingController();
  String? _kategori;

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    context.read<BelanjaModel>().tambah(
      _nama.text,
      int.parse(_jumlah.text),
      _kategori!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barang ditambahkan'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Belanja'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(
                  labelText: 'Nama barang',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jumlah,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final jumlah = int.tryParse(v ?? '');
                  return jumlah == null || jumlah <= 0
                      ? 'Jumlah harus lebih dari 0'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Makanan',
                    child: Text('Makanan'),
                  ),
                  DropdownMenuItem(
                    value: 'Minuman',
                    child: Text('Minuman'),
                  ),
                  DropdownMenuItem(
                    value: 'Kebutuhan Rumah',
                    child: Text('Kebutuhan Rumah'),
                  ),
                  DropdownMenuItem(
                    value: 'Lainnya',
                    child: Text('Lainnya'),
                  ),
                ],
                onChanged: (v) => setState(() => _kategori = v),
                validator: (v) =>
                v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}