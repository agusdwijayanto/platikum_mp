import 'package:flutter/material.dart';

//Tambah import:
import 'pages/dashboard.dart';
import 'pages/login_page.dart';
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
      routes: {
        '/': (_) => const LoginPage(),
        '/dashboard': (_) => const Dashboard(),
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
