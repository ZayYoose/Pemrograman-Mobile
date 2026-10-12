import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String? dibuat;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
    this.dibuat,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'judul': judul,
    'isi': isi,
    'dibuat': dibuat,
  };

  factory Catatan.fromMap(Map<String, Object?> m) => Catatan(
    id: m['id'] as int,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    dibuat: m['dibuat'] as String?,
  );
}

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final path = p.join(
      await getDatabasesPath(),
      'catatan.db',
    );

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE catatan('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'judul TEXT NOT NULL, '
              'isi TEXT NOT NULL, '
              'dibuat TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE catatan ADD COLUMN dibuat TEXT',
          );
        }
      },
    );

    return _db!;
  }

  static Future<int> tambah(Catatan c) async {
    final db = await database;
    return db.insert('catatan', c.toMap());
  }

  static Future<List<Catatan>> semua({
    String kata = '',
    String urutan = 'terbaru',
  }) async {
    final db = await database;

    final rows = await db.query(
      'catatan',
      where: 'judul LIKE ?',
      whereArgs: ['%$kata%'],
      orderBy: urutan == 'terbaru'
          ? 'dibuat DESC'
          : 'dibuat ASC',
    );

    return rows.map(Catatan.fromMap).toList();
  }

  static Future<int> ubah(Catatan c) async {
    final db = await database;

    return db.update(
      'catatan',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'catatan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 5',
      home: const CatatanPage(),
    );
  }
}

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  late Future<List<Catatan>> _future;

  final _pencarian = TextEditingController();

  String _urutan = 'terbaru';

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();

    _urutan = prefs.getString('urutan') ?? 'terbaru';

    _muat();
  }

  void _muat() {
    setState(() {
      _future = DbHelper.semua(
        kata: _pencarian.text.trim(),
        urutan: _urutan,
      );
    });
  }

  Future<void> _simpanUrutan(String nilai) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('urutan', nilai);

    setState(() {
      _urutan = nilai;
      _future = DbHelper.semua(
        kata: _pencarian.text.trim(),
        urutan: _urutan,
      );
    });
  }

  Future<void> _buka([Catatan? catatan]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormCatatanPage(
          catatan: catatan,
        ),
      ),
    );

    if (!mounted) return;

    _muat();
  }

  Future<void> _konfirmasiHapus(Catatan catatan) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Hapus catatan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (hasil == true) {
      await DbHelper.hapus(catatan.id!);
      _muat();
    }
  }

  @override
  void dispose() {
    _pencarian.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        actions: [
          DropdownButton<String>(
            value: _urutan,
            items: const [
              DropdownMenuItem(
                value: 'terbaru',
                child: Text('Terbaru'),
              ),
              DropdownMenuItem(
                value: 'terlama',
                child: Text('Terlama'),
              ),
            ],
            onChanged: (nilai) {
              if (nilai != null) {
                _simpanUrutan(nilai);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _pencarian,
              decoration: const InputDecoration(
                labelText: 'Cari judul',
                border: OutlineInputBorder(),
              ),
              onChanged: (kata) {
                _muat();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Catatan>>(
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
                    child: Text(
                      'Galat: ${snapshot.error}',
                    ),
                  );
                }

                final data = snapshot.data!;

                if (data.isEmpty) {
                  return const Center(
                    child: Text('Belum ada catatan'),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final c = data[i];

                    return ListTile(
                      title: Text(c.judul),
                      subtitle: Text(
                        c.isi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _buka(c),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _konfirmasiHapus(c);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormCatatanPage extends StatefulWidget {
  final Catatan? catatan;

  const FormCatatanPage({
    super.key,
    this.catatan,
  });

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judul;
  late final TextEditingController _isi;

  @override
  void initState() {
    super.initState();

    _judul = TextEditingController(
      text: widget.catatan?.judul ?? '',
    );

    _isi = TextEditingController(
      text: widget.catatan?.isi ?? '',
    );
  }

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final c = Catatan(
      id: widget.catatan?.id,
      judul: _judul.text.trim(),
      isi: _isi.text.trim(),
      dibuat: widget.catatan?.dibuat ??
          DateTime.now().toIso8601String(),
    );

    if (widget.catatan == null) {
      await DbHelper.tambah(c);
    } else {
      await DbHelper.ubah(c);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.catatan == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baru ? 'Catatan Baru' : 'Ubah Catatan',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty)
                  ? 'Judul wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _isi,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Isi catatan',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty)
                  ? 'Isi wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
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