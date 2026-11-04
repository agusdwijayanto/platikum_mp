import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Profil membaca akun Supabase yang sedang login: email dari sesi,
// data lainnya dari metadata yang diisi saat registrasi.
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final akun = Supabase.instance.client.auth.currentUser;
    final meta = akun?.userMetadata ?? const <String, dynamic>{};

    String isi(String kunci) {
      final nilai = meta[kunci]?.toString() ?? '';
      return nilai.isEmpty ? '-' : nilai;
    }

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
          Text('Nama: ${isi('nama')}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('NIM: ${isi('nim')}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Email: ${akun?.email ?? '-'}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('No. HP: ${isi('no_hp')}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Jenis Kelamin: ${isi('jenis_kelamin')}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Hobi: ${isi('hobi')}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Kelas: 04SIFE002',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              // Akhiri sesi, kembali ke gerbang, bersihkan tumpukan halaman.
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
