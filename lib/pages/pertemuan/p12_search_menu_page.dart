import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class P12SearchMenuPage extends StatefulWidget {
  const P12SearchMenuPage({super.key});

  @override
  State<P12SearchMenuPage> createState() => _P12State();
}

class _P12State extends State<P12SearchMenuPage> {
  // Controller wajib di-dispose agar tidak bocor memori
  final _searchController = TextEditingController();

  String _query = '';
  bool _tampilkanSelesai = true;

  final List<Map<String, dynamic>> _daftarTugas = [
    {'nama': 'Buat laporan praktikum', 'selesai': true},
    {'nama': 'Kerjakan tugas algoritma', 'selesai': false},
    {'nama': 'Review materi Flutter', 'selesai': true},
    {'nama': 'Push kode ke GitHub', 'selesai': false},
    {'nama': 'Buat slide presentasi', 'selesai': false},
    {'nama': 'Tes unit widget baru', 'selesai': true},
    {'nama': 'Baca dokumentasi Dart', 'selesai': false},
    {'nama': 'Diskusi kelompok capstone', 'selesai': true},
  ];

  List<Map<String, dynamic>> get _filtered {
    return _daftarTugas.where((t) {
      final cocok = t['nama'].toString().toLowerCase().contains(_query.toLowerCase());
      // Sembunyikan tugas selesai jika saklar mati
      final tampil = _tampilkanSelesai ? true : !(t['selesai'] as bool);
      return cocok && tampil;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _dialogTambah() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama tugas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final nama = ctrl.text.trim();
              if (nama.isNotEmpty) {
                setState(() => _daftarTugas.add({'nama': nama, 'selesai': false}));
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  void _dialogPengaturan() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Pengaturan'),
          content: SwitchListTile(
            title: const Text('Tampilkan tugas selesai'),
            value: _tampilkanSelesai,
            onChanged: (val) {
              setLocal(() => _tampilkanSelesai = val);
              // Saklar nyata: langsung update daftar di halaman utama
              setState(() => _tampilkanSelesai = val);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogKeluar() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text('Yakin ingin menutup aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search View & Option Menu'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              switch (val) {
                case 'tambah':
                  _dialogTambah();
                case 'pengaturan':
                  _dialogPengaturan();
                case 'tentang':
                  showAboutDialog(
                    context: context,
                    applicationName: 'Praktikum MP',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 Praktikum Mobile Programming',
                  );
                case 'keluar':
                  _dialogKeluar();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'tambah', child: Text('Tambah Data')),
              PopupMenuItem(value: 'pengaturan', child: Text('Pengaturan')),
              PopupMenuItem(value: 'tentang', child: Text('Tentang Aplikasi')),
              PopupMenuItem(value: 'keluar', child: Text('Keluar')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Cari tugas...',
              leading: const Icon(Icons.search),
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          Expanded(
            child: data.isEmpty
                ? const Center(child: Text('Tidak ada data'))
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (_, i) {
                      final tugas = data[i];
                      return CheckboxListTile(
                        title: Text(
                          tugas['nama'],
                          style: TextStyle(
                            // Coret teks kalau tugas sudah selesai
                            decoration: tugas['selesai']
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        value: tugas['selesai'],
                        onChanged: (val) {
                          setState(() => tugas['selesai'] = val ?? false);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
