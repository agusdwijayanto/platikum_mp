import 'package:flutter/material.dart';

//Tambah import:
import 'pages/dashboard.dart';
import 'pages/register_page.dart';
import 'pages/pertemuan/p0_page.dart';
import 'pages/pertemuan/p1_page.dart';
import 'pages/pertemuan/p2_page.dart';
import 'pages/pertemuan/p3_listview.dart';
import 'pages/pertemuan/p4_toastalert.dart';
import 'pages/pertemuan/p5_gesturedetector.dart';
import 'pages/pertemuan/p6_form_page.dart';
import 'pages/pertemuan/p8_todo_page.dart';
import 'pages/pertemuan/p9_autentikasi_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum Mobile Programming',
      debugShowCheckedModeBanner: false,
      // Tema minimal terang untuk seluruh aplikasi: latar terang,
      // AppBar biru primary, kartu bersudut bulat.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE8EAED)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      routes: {
        // Pintu depan aplikasi: login email Supabase (halaman Pertemuan 9
        // dalam mode gerbang). Sesudah login pengguna diteruskan ke
        // Dashboard, dan sesi yang masih aktif membuat aplikasi
        // langsung masuk Dashboard pada pembukaan berikutnya.
        '/': (_) => const P9AutentikasiPage(sebagaiGerbang: true),
        '/dashboard': (_) => const Dashboard(),
        '/register': (_) => const RegisterPage(),
        //Tambah route
        '/p0': (_) => const P0Page(),
        '/p1': (_) => const P1Page(),
        '/p2': (_) => const P2Page(),
        '/p3': (_) => const P3ListView(),
        '/p4': (_) => const P4ToastAlert(),
        '/p5': (_) => const P5Gesturedetector(),
        '/p6': (_) => const P6_FormPage(),
        '/p8': (_) => const P8TodoPage(),
        '/p9': (_) => const P9AutentikasiPage(),
      },
    );
  }
}
