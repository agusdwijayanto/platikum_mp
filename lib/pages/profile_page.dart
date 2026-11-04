import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilPage extends StatelessWidget {
  final Map<String, dynamic>? user;

  const ProfilPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final nama = user?['nama'] ?? 'Agus Dwijayanto';
    final nim = user?['nim'] ?? '241011750001';
    final email = user?['email'] ?? '-';
    final noHp = user?['no_hp'] ?? '-';
    final jenisKelamin = user?['jenis_kelamin'] ?? '-';
    final hobi = user?['hobi'] ?? '-';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
              radius: 50, child: Icon(Icons.person, size: 60)),
          const SizedBox(height: 16),
          const Text(
            'Profil Mahasiswa',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Nama: $nama', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('NIM: $nim', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Email: $email', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('No. HP: $noHp', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Jenis Kelamin: $jenisKelamin',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Hobi: $hobi', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Kelas: 04SIFE002',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              // Logout yang sama dengan di seluruh aplikasi: sesi
              // Supabase diakhiri, lalu kembali ke gerbang login dan
              // tumpukan halaman dibersihkan.
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
