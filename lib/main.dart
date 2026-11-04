import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

// Konfigurasi Supabase — isi dari dashboard Supabase: Settings lalu API.
// Nilai yang sama juga dipakai di p8_todo_page.dart.
const String supabaseUrl = 'https://abateiobysegtdgklnwi.supabase.co';
const String supabaseAnonKey = 'sb_publishable_cuTjsQsW3gihnDZJOD_FzA_nN253Ezc';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Supabase untuk fitur autentikasi Pertemuan 9.
  // SDK ini juga yang menyimpan sesi login secara lokal, sehingga
  // pengguna tetap login sesudah aplikasi ditutup dan dibuka lagi.
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}
