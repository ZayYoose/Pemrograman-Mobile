
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'nama': nama,
    'jumlah': jumlah,
    'kategori': kategori,
    'tanggal': tanggal,
  };

  factory Pengeluaran.fromMap(Map<String, Object?> m) =>
      Pengeluaran(
        id: m['id'] as int,
        nama: m['nama'] as String,
        jumlah: m['jumlah'] as int,
        kategori: m['kategori'] as String,
        tanggal: m['tanggal'] as String,
      );
}

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final path = p.join(
      await getDatabasesPath(),
      'pengeluaran.db',
    );

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pengeluaran('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'nama TEXT NOT NULL, '
              'jumlah INTEGER NOT NULL, '
              'kategori TEXT NOT NULL, '
              'tanggal TEXT NOT NULL)',
        );
      },
    );

    return _db!;
  }

  static Future<int> tambah(Pengeluaran data) async {
    final db = await database;
    return db.insert('pengeluaran', data.toMap());
  }

  static Future<List<Pengeluaran>> semua() async {
    final db = await database;

    final rows = await db.query(
      'pengeluaran',
      orderBy: 'id DESC',
    );

    return rows.map(Pengeluaran.fromMap).toList();
  }

  static Future<int> ubah(Pengeluaran data) async {
    final db = await database;

    return db.update(
      'pengeluaran',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'pengeluaran',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _gelap = false;

  @override
  void initState() {
    super.initState();
    _muatTema();
  }

  Future<void> _muatTema() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _gelap = prefs.getBool('modeGelap') ?? false;
    });
  }

  Future<void> _ubahTema(bool nilai) async {
    setState(() {
      _gelap = nilai;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modeGelap', nilai);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Pengeluaran',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: _gelap ? ThemeMode.dark : ThemeMode.light,
      home: PengeluaranPage(
        gelap: _gelap,
        onTemaChanged: _ubahTema,
      ),
    );
  }
}

class PengeluaranPage extends StatefulWidget {
  final bool gelap;
  final ValueChanged<bool> onTemaChanged;

  const PengeluaranPage({
    super.key,
    required this.gelap,
    required this.onTemaChanged,
  });

  @override
  State<PengeluaranPage> createState() =>
      _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  late Future<List<Pengeluaran>> _future;

  @override
  void initState() {
    super.initState();
    _future = DbHelper.semua();
  }

  void _muat() {
    setState(() {
      _future = DbHelper.semua();
    });
  }

  Future<void> _buka([Pengeluaran? data]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengeluaranPage(data: data),
      ),
    );

    if (!mounted) return;

    _muat();
  }

  Future<void> _konfirmasiHapus(Pengeluaran data) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Hapus pengeluaran ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (hasil == true) {
      await DbHelper.hapus(data.id!);

      if (!mounted) return;

      _muat();
    }
  }

  String _rupiah(int jumlah) {
    final angka = jumlah.toString();
    final hasil = StringBuffer();

    for (int i = 0; i < angka.length; i++) {
      hasil.write(angka[i]);

      final sisa = angka.length - i - 1;

      if (sisa > 0 && sisa % 3 == 0) {
        hasil.write('.');
      }
    }

    return 'Rp $hasil';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatat Pengeluaran'),
        actions: [
          IconButton(
            tooltip: 'Ubah mode tema',
            onPressed: () {
              widget.onTemaChanged(!widget.gelap);
            },
            icon: Icon(
              widget.gelap
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Pengeluaran>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Galat: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          int total = 0;

          for (final item in data) {
            total += item.jumlah;
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Total Pengeluaran'),
                      const SizedBox(height: 8),
                      Text(
                        _rupiah(total),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: data.isEmpty
                    ? const Center(
                  child: Text(
                    'Belum ada pengeluaran',
                  ),
                )
                    : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final item = data[i];

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.receipt_long,
                        ),
                      ),
                      title: Text(item.nama),
                      subtitle: Text(
                        '${item.kategori} • '
                            '${item.tanggal.split('T')[0]}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _rupiah(item.jumlah),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed: () {
                              _konfirmasiHapus(item);
                            },
                          ),
                        ],
                      ),
                      onTap: () => _buka(item),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? data;

  const FormPengeluaranPage({
    super.key,
    this.data,
  });

  @override
  State<FormPengeluaranPage> createState() =>
      _FormPengeluaranPageState();
}

class _FormPengeluaranPageState
    extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _jumlah;

  final List<String> _kategoriList = [
    'Makanan',
    'Transportasi',
    'Pendidikan',
    'Belanja',
    'Hiburan',
    'Lainnya',
  ];

  late String _kategori;

  @override
  void initState() {
    super.initState();

    _nama = TextEditingController(
      text: widget.data?.nama ?? '',
    );

    _jumlah = TextEditingController(
      text: widget.data?.jumlah.toString() ?? '',
    );

    _kategori = widget.data?.kategori ?? 'Makanan';
  }

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final data = Pengeluaran(
      id: widget.data?.id,
      nama: _nama.text.trim(),
      jumlah: int.parse(_jumlah.text.trim()),
      kategori: _kategori,
      tanggal: widget.data?.tanggal ??
          DateTime.now().toIso8601String(),
    );

    if (widget.data == null) {
      await DbHelper.tambah(data);
    } else {
      await DbHelper.ubah(data);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.data == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baru ? 'Tambah Pengeluaran' : 'Ubah Pengeluaran',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama pengeluaran',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }

                final angka = int.tryParse(v.trim());

                if (angka == null) {
                  return 'Jumlah harus berupa angka bulat';
                }

                if (angka <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: _kategoriList.map((kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (nilai) {
                if (nilai != null) {
                  setState(() {
                    _kategori = nilai;
                  });
                }
              },
              validator: (nilai) {
                if (nilai == null || nilai.isEmpty) {
                  return 'Kategori wajib dipilih';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _simpan,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
