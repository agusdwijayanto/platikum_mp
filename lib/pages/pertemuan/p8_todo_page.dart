import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// URL dan kunci publishable project Supabase (flutterlab).
const String supabaseUrl = 'https://abateiobysegtdgklnwi.supabase.co';
const String supabaseAnonKey = 'sb_publishable_cuTjsQsW3gihnDZJOD_FzA_nN253Ezc';

class P8TodoPage extends StatefulWidget {
  const P8TodoPage({super.key});

  @override
  State<P8TodoPage> createState() => _P8TodoPageState();
}

class _P8TodoPageState extends State<P8TodoPage> {
  List<dynamic> _daftarTugas = [];
  bool _sedangMuat = true;
  String? _pesanError;

  final _judulController = TextEditingController();

  Session? get _sesi => Supabase.instance.client.auth.currentSession;
  User? get _pengguna => Supabase.instance.client.auth.currentUser;

  // Data tetap diambil dengan http mentah; SDK hanya dipinjam
  // sesinya. Authorization memakai token sesi, bukan kunci
  // publishable, supaya RLS hanya mengembalikan tugas milik
  // pengguna yang sedang login.
  Map<String, String> _header() {
    return {
      'apikey': supabaseAnonKey,
      'Authorization': 'Bearer ${_sesi?.accessToken ?? supabaseAnonKey}',
      'Content-Type': 'application/json',
    };
  }

  String get _alamatTodos => '$supabaseUrl/rest/v1/todos';

  @override
  void initState() {
    super.initState();
    ambilTugas();
  }

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  void _tampilPesan(String pesan) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> ambilTugas() async {
    if (_pengguna == null) {
      setState(() {
        _sedangMuat = false;
        _pesanError = 'Belum ada sesi login. Silakan login dulu.';
      });
      return;
    }
    setState(() {
      _sedangMuat = true;
      _pesanError = null;
    });
    try {
      final response = await http.get(
        Uri.parse('$_alamatTodos?select=*&order=id.asc'),
        headers: _header(),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _daftarTugas = jsonDecode(response.body) as List<dynamic>;
          _sedangMuat = false;
        });
      } else {
        setState(() {
          _pesanError =
              'Gagal mengambil data (${response.statusCode}): ${response.body}';
          _sedangMuat = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pesanError = 'Tidak bisa terhubung ke server: $e';
        _sedangMuat = false;
      });
    }
  }

  Future<void> tambahTugas() async {
    final judul = _judulController.text.trim();
    if (judul.isEmpty || _pengguna == null) return;
    try {
      final response = await http.post(
        Uri.parse(_alamatTodos),
        headers: _header(),
        body: jsonEncode({'judul': judul, 'user_id': _pengguna!.id}),
      );
      if (!mounted) return;
      if (response.statusCode == 201) {
        _judulController.clear();
        Navigator.pop(context);
        _tampilPesan('Tugas ditambahkan');
        ambilTugas();
      } else {
        _tampilPesan(
          'Gagal menambah tugas (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _tampilPesan('Tidak bisa terhubung ke server: $e');
    }
  }

  Future<void> ubahStatusTugas(
    Map<String, dynamic> tugas,
    bool selesai,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_alamatTodos?id=eq.${tugas['id']}'),
        headers: _header(),
        body: jsonEncode({'selesai': selesai}),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 204) {
        ambilTugas();
      } else {
        _tampilPesan(
          'Gagal mengubah tugas (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _tampilPesan('Tidak bisa terhubung ke server: $e');
    }
  }

  Future<void> hapusTugas(Map<String, dynamic> tugas) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text('Hapus tugas "${tugas['judul']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    try {
      final response = await http.delete(
        Uri.parse('$_alamatTodos?id=eq.${tugas['id']}'),
        headers: _header(),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 204) {
        _tampilPesan('Tugas dihapus');
        ambilTugas();
      } else {
        _tampilPesan(
          'Gagal menghapus tugas (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _tampilPesan('Tidak bisa terhubung ke server: $e');
    }
  }

  void _dialogTambahTugas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: TextField(
          controller: _judulController,
          decoration: const InputDecoration(
            labelText: 'Judul tugas',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(onPressed: tambahTugas, child: const Text('Tambah')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertemuan 8 - To-Do List API'),
      ),
      body: _isiBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _dialogTambahTugas,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _isiBody() {
    if (_sedangMuat) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pesanError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_pesanError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: ambilTugas,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_daftarTugas.isEmpty) {
      return const Center(child: Text('Belum ada tugas'));
    }
    return RefreshIndicator(
      onRefresh: ambilTugas,
      child: ListView.builder(
        itemCount: _daftarTugas.length,
        itemBuilder: (context, index) {
          final tugas = _daftarTugas[index] as Map<String, dynamic>;
          final selesai = tugas['selesai'] == true;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Checkbox(
                value: selesai,
                onChanged: (value) => ubahStatusTugas(tugas, value ?? false),
              ),
              title: Text(
                tugas['judul'] ?? '',
                style: TextStyle(
                  decoration: selesai ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => hapusTugas(tugas),
              ),
            ),
          );
        },
      ),
    );
  }
}
