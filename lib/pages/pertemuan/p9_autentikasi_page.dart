import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Pertemuan 9: Autentikasi dan Manajemen Sesi dengan Supabase.
//
// Alurnya:
// 1. Pengguna login dengan email dan password (Supabase Auth).
// 2. Sesudah login, email pengguna ditampilkan di bagian atas dan
//    daftar tugasnya dimuat. Aturan RLS di tabel todos memastikan
//    tiap akun hanya melihat tugas miliknya sendiri.
// 3. Sesi disimpan otomatis oleh supabase_flutter di penyimpanan
//    lokal, jadi sesudah aplikasi ditutup lalu dibuka lagi
//    pengguna tetap login tanpa mengisi form lagi.
// 4. Tombol Logout menghapus sesi dan kembali ke form login.
class P9AutentikasiPage extends StatefulWidget {
  // Mode gerbang: halaman ini dipakai sebagai pintu depan aplikasi.
  // Begitu ada sesi login yang aktif, pengguna diteruskan ke
  // Dashboard dan tidak tinggal di daftar tugas halaman ini.
  final bool sebagaiGerbang;

  const P9AutentikasiPage({super.key, this.sebagaiGerbang = false});

  @override
  State<P9AutentikasiPage> createState() => _P9AutentikasiPageState();
}

class _P9AutentikasiPageState extends State<P9AutentikasiPage> {
  final _supabase = Supabase.instance.client;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _judulController = TextEditingController();

  StreamSubscription<AuthState>? _langgananAuth;
  List<dynamic> _daftarTugas = [];
  bool _memuatTugas = false;
  bool _memprosesLogin = false;
  bool _sudahPindah = false;

  User? get _pengguna => _supabase.auth.currentUser;

  // Dalam mode gerbang, pengguna yang sesinya aktif langsung
  // diteruskan ke Dashboard. Penanda _sudahPindah menjaga
  // navigasi hanya terjadi satu kali.
  void _teruskanKeDashboard() {
    if (!widget.sebagaiGerbang || _sudahPindah || _pengguna == null) {
      return;
    }
    _sudahPindah = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }

  @override
  void initState() {
    super.initState();
    // Dengarkan perubahan status login dan logout. Listener ini juga
    // terpanggil saat aplikasi dibuka dan sesi lama dipulihkan dari
    // penyimpanan lokal, di situlah efek "tetap login" terlihat.
    _langgananAuth = _supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      setState(() {});
      _teruskanKeDashboard();
      if (_pengguna != null && !widget.sebagaiGerbang) {
        ambilTugas();
      }
    });
    _teruskanKeDashboard();
    if (_pengguna != null && !widget.sebagaiGerbang) {
      ambilTugas();
    }
  }

  @override
  void dispose() {
    _langgananAuth?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _judulController.dispose();
    super.dispose();
  }

  void _tampilPesan(String pesan) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // Login dengan email dan password yang sudah terdaftar.
  // Berhasil: listener auth mengganti tampilan ke daftar tugas.
  // Gagal: AuthException berisi pesan dari server, ditampilkan apa adanya.
  Future<void> login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _tampilPesan('Email dan password wajib diisi');
      return;
    }
    setState(() => _memprosesLogin = true);
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      _tampilPesan('Login gagal: ${e.message}');
    } catch (e) {
      _tampilPesan('Tidak bisa terhubung ke server: $e');
    } finally {
      if (mounted) setState(() => _memprosesLogin = false);
    }
  }

  // Mendaftarkan akun baru. Kalau server meminta konfirmasi email,
  // session masih kosong dan pengguna diminta cek email dulu.
  Future<void> daftar() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _tampilPesan('Email dan password wajib diisi');
      return;
    }
    setState(() => _memprosesLogin = true);
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.session == null) {
        _tampilPesan(
          'Pendaftaran berhasil. Cek email untuk konfirmasi, lalu login.',
        );
      }
    } on AuthException catch (e) {
      _tampilPesan('Daftar gagal: ${e.message}');
    } catch (e) {
      _tampilPesan('Tidak bisa terhubung ke server: $e');
    } finally {
      if (mounted) setState(() => _memprosesLogin = false);
    }
  }

  // Logout: sesi dihapus dari server dan dari penyimpanan lokal.
  // Di mode gerbang, listener auth mengembalikan tampilan ke form
  // login di halaman ini juga. Dari halaman Materi, pengguna dibawa
  // pulang ke gerbang (keluar dari aplikasi) dan tumpukan halaman
  // dibersihkan, supaya tombol kembali tidak bisa masuk lagi ke
  // Dashboard dalam keadaan sudah logout.
  Future<void> logout() async {
    await _supabase.auth.signOut();
    if (!mounted || widget.sebagaiGerbang) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // Mengambil tugas milik pengguna yang sedang login.
  // Berkat RLS, server hanya mengembalikan baris yang user_id-nya
  // sama dengan id pengguna, jadi filter manual tidak diperlukan.
  Future<void> ambilTugas() async {
    setState(() => _memuatTugas = true);
    try {
      final data = await _supabase.from('todos').select().order('id');
      if (!mounted) return;
      setState(() {
        _daftarTugas = data;
        _memuatTugas = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => _memuatTugas = false);
      _tampilPesan('Gagal mengambil tugas: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _memuatTugas = false);
      _tampilPesan('Tidak bisa terhubung ke server: $e');
    }
  }

  // Tugas baru selalu dicatat dengan user_id pemiliknya,
  // sesuai tuntutan kolom with check pada policy RLS.
  Future<void> tambahTugas() async {
    final judul = _judulController.text.trim();
    final pengguna = _pengguna;
    if (judul.isEmpty || pengguna == null) return;
    try {
      await _supabase.from('todos').insert({
        'judul': judul,
        'user_id': pengguna.id,
      });
      if (!mounted) return;
      _judulController.clear();
      Navigator.pop(context);
      _tampilPesan('Tugas ditambahkan');
      ambilTugas();
    } on PostgrestException catch (e) {
      _tampilPesan('Gagal menambah tugas: ${e.message}');
    } catch (e) {
      _tampilPesan('Tidak bisa terhubung ke server: $e');
    }
  }

  Future<void> ubahStatusTugas(
    Map<String, dynamic> tugas,
    bool selesai,
  ) async {
    try {
      await _supabase
          .from('todos')
          .update({'selesai': selesai})
          .eq('id', tugas['id']);
      if (!mounted) return;
      ambilTugas();
    } on PostgrestException catch (e) {
      _tampilPesan('Gagal mengubah tugas: ${e.message}');
    } catch (e) {
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
      await _supabase.from('todos').delete().eq('id', tugas['id']);
      if (!mounted) return;
      _tampilPesan('Tugas dihapus');
      ambilTugas();
    } on PostgrestException catch (e) {
      _tampilPesan('Gagal menghapus tugas: ${e.message}');
    } catch (e) {
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
    // Mode gerbang: sesi sudah ada dan penerusan ke Dashboard
    // sedang disiapkan, tampilkan indikator muat sebentar.
    if (widget.sebagaiGerbang && _pengguna != null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sebagaiGerbang
              ? 'Praktikum Mobile Programming'
              : 'Pertemuan 9 - Autentikasi',
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: _pengguna == null ? _formLogin() : _tampilanTugas(),
      floatingActionButton: _pengguna == null
          ? null
          : FloatingActionButton(
              onPressed: _dialogTambahTugas,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _formLogin() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.lock, size: 64, color: Colors.blueAccent),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _memprosesLogin ? null : login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: _memprosesLogin
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : const Text('Login'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _memprosesLogin ? null : daftar,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Daftar Akun Baru'),
        ),
      ],
    );
  }

  Widget _tampilanTugas() {
    final pengguna = _pengguna!;
    return Column(
      children: [
        // Kepala halaman: email pengguna yang sedang login + Logout.
        Container(
          width: double.infinity,
          color: Colors.blue.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.account_circle),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pengguna.email ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
        Expanded(child: _isiDaftarTugas()),
      ],
    );
  }

  Widget _isiDaftarTugas() {
    if (_memuatTugas) {
      return const Center(child: CircularProgressIndicator());
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
