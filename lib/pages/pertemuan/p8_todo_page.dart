import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// Konfigurasi Supabase.
// Ambil dari dashboard Supabase: Settings lalu API.
// Dua nilai ini dipakai di setiap request sebagai identitas aplikasi,
// supaya server Supabase mengenali siapa yang meminta data.
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

  // Sesi login dibaca dari supabase_flutter, hanya untuk mengambil
  // token dan id pengguna yang sedang login (Pertemuan 9). Seluruh
  // lalu lintas data halaman ini tetap memakai http mentah sesuai
  // materi Pertemuan 8, bukan SDK.
  Session? get _sesi => Supabase.instance.client.auth.currentSession;
  User? get _pengguna => Supabase.instance.client.auth.currentUser;

  // Header yang dikirim di semua request:
  // - apikey: kunci publik project Supabase, tanda pengenal aplikasi.
  // - Authorization: Bearer + token sesi pengguna yang sedang login.
  //   Token inilah yang dibaca aturan RLS di server, sehingga data
  //   yang kembali hanya tugas milik pengguna tersebut.
  // - Content-Type: memberi tahu server bahwa isi request berformat JSON.
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

  // GET: mengambil daftar tugas dari server.
  // Respons berhasil = status 200, isi body berupa JSON daftar tugas.
  // Respons gagal = status selain 200, pesan error ditampilkan ke pengguna.
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

  // POST: mengirim tugas baru untuk disimpan di server.
  // Respons berhasil = status 201 (data baru berhasil dibuat).
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

  // PATCH: mengubah sebagian data tugas yang sudah ada.
  // Di sini hanya kolom selesai yang dikirim, judul tidak ikut diubah.
  // Tugas yang diubah ditunjuk lewat id pada alamat (?id=eq.<id>).
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

  // DELETE: menghapus tugas dari server berdasarkan id-nya.
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
        backgroundColor: Colors.blueAccent,
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
          return ListTile(
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
          );
        },
      ),
    );
  }
}
