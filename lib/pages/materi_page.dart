import 'package:flutter/material.dart';

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _materiCard(
          context,
          icon: Icons.book,
          title: 'Pertemuan 1',
          subtitle: 'Pengenalan Mobile Programming',
          route: '/p1',
        ),
        _materiCard(
          context,
          icon: Icons.book,
          title: 'Pertemuan 2',
          subtitle: 'Membuat Tampilan Aplikasi Flutter',
          route: '/p2',
        ),
        _materiCard(
          context,
          icon: Icons.code,
          title: 'Pertemuan 3',
          subtitle: 'Latihan ListView',
          route: '/p3',
        ),
        _materiCard(
          context,
          icon: Icons.code,
          title: 'Pertemuan 4',
          subtitle: 'Latihan Toast Alert',
          route: '/p4',
        ),
        _materiCard(
          context,
          icon: Icons.touch_app,
          title: 'Pertemuan 5',
          subtitle: 'Latihan Gesture Detector',
          route: '/p5',
        ),
        _materiCard(
          context,
          icon: Icons.create,
          title: 'Pertemuan 6',
          subtitle: 'Latihan Form',
          route: '/p6',
        ),
        _materiCard(
          context,
          icon: Icons.api,
          title: 'Pertemuan 8',
          subtitle: 'Penggunaan API - To-Do List Supabase',
          route: '/p8',
        ),
        _materiCard(
          context,
          icon: Icons.lock,
          title: 'Pertemuan 9',
          subtitle: 'Autentikasi dan Manajemen Sesi',
          route: '/p9',
        ),
        _materiCard(
          context,
          icon: Icons.phone_android,
          title: 'Pertemuan 10',
          subtitle: 'Native dan Sensor',
          route: '/p10',
        ),
      ],
    );
  }

  Widget _materiCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
