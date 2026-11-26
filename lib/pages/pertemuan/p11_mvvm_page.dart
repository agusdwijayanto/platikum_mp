import 'package:flutter/material.dart';

class P11MvvmPage extends StatelessWidget {
  const P11MvvmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertemuan 11 - Arsitektur MVVM'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'MVVM itu apa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'MVVM adalah singkatan dari Model, View, dan ViewModel. '
              'Pola ini memisahkan kode aplikasi menjadi tiga bagian, '
              'supaya kode lebih mudah dibaca dan dirawat.',
            ),
            SizedBox(height: 16),
            Text(
              'Model',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Model berisi data Todo, yaitu id, judul, selesai, dan user_id. '
              'Ada fromJson dan toJson. '
              'File: lib/models/todo_model.dart.',
            ),
            SizedBox(height: 16),
            Text(
              'ViewModel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'ViewModel berisi state dan logika. '
              'State-nya daftar tugas, sedang memuat, dan pesan error. '
              'Logikanya muat tugas, tambah tugas, ubah status, dan hapus tugas. '
              'Untuk mengambil data dari Supabase saya pakai header apikey dan '
              'token Bearer dari sesi login, plus user_id. '
              'File: lib/viewmodels/todo_viewmodel.dart.',
            ),
            SizedBox(height: 16),
            Text(
              'View',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'View hanya berisi tampilan. Kalau pengguna menekan tombol, '
              'View meneruskan ke ViewModel. Kalau ada perubahan, View ikut '
              'berubah karena mendengarkan ViewModel lewat ListenableBuilder. '
              'File: lib/pages/pertemuan/p8_todo_page.dart.',
            ),
            SizedBox(height: 16),
            Text(
              'Cara kerjanya',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'View minta data ke ViewModel, ViewModel mengambil data dari '
              'Supabase, lalu View ikut berubah. '
              'Saya tidak menambah package baru.',
            ),
            SizedBox(height: 16),
            Text(
              'Tugasnya di mana',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Contoh penerapan MVVM ini ada di Pertemuan 8, '
              'pada fitur To-Do List.',
            ),
          ],
        ),
      ),
    );
  }
}
