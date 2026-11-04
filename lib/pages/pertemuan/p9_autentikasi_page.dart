import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Pertemuan 9: autentikasi dan manajemen sesi Supabase.
//
// Satu-satunya pintu login aplikasi. Sebagai gerbang (route '/'),
// halaman ini meneruskan pengguna yang sesinya masih aktif ke
// Dashboard. Dari Materi, halaman ini hanya menampilkan akun yang
// sedang login; daftar tugas ada di Pertemuan 8, Logout di Profil.
class P9AutentikasiPage extends StatefulWidget {
  final bool sebagaiGerbang;

  const P9AutentikasiPage({super.key, this.sebagaiGerbang = false});

  @override
  State<P9AutentikasiPage> createState() => _P9AutentikasiPageState();
}

class _P9AutentikasiPageState extends State<P9AutentikasiPage> {
  final _supabase = Supabase.instance.client;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  StreamSubscription<AuthState>? _langgananAuth;
  bool _memprosesLogin = false;
  bool _sudahPindah = false;

  User? get _pengguna => _supabase.auth.currentUser;

  // Penanda _sudahPindah menjaga navigasi hanya terjadi satu kali.
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
    // Listener ini juga terpanggil saat sesi lama dipulihkan dari
    // penyimpanan lokal ketika aplikasi dibuka; di situlah efek
    // tetap login sesudah aplikasi ditutup berasal.
    _langgananAuth = _supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      setState(() {});
      _teruskanKeDashboard();
    });
    _teruskanKeDashboard();
  }

  @override
  void dispose() {
    _langgananAuth?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _tampilPesan(String pesan) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(pesan)));
  }

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


  @override
  Widget build(BuildContext context) {
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
      ),
      body: _pengguna == null ? _formLogin() : _infoAkun(),
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
          onPressed: () => Navigator.pushNamed(context, '/register'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Daftar Akun Baru'),
        ),
      ],
    );
  }

  Widget _infoAkun() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_circle,
            size: 72,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 12),
          const Text('Masuk sebagai'),
          const SizedBox(height: 4),
          Text(
            _pengguna?.email ?? '-',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
