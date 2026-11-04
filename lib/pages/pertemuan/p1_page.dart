import 'package:flutter/material.dart';

class P1Page extends StatelessWidget {
  const P1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertemuan 1'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionTitle('Alur Tambah Pertemuan Baru'),
          _StepTile(
            nomor: '1',
            judul: 'Buat file baru',
            detail:
                'lib/pages/pertemuan/p4_page.dart\n'
                'class: P4Page',
          ),
          _StepTile(
            nomor: '2',
            judul: 'Daftarkan di app.dart',
            detail:
                "import 'pages/pertemuan/p4_page.dart';\n"
                "'/p4': (_) => const P4Page(),",
          ),
          _StepTile(
            nomor: '3',
            judul: 'Tambah card di materi_page.dart',
            detail:
                "_materiCard(\n"
                "  context,\n"
                "  icon: Icons.grid_view,\n"
                "  title: 'Pertemuan 4',\n"
                "  subtitle: 'Nama materi',\n"
                "  route: '/p4',\n"
                ")",
          ),
          _StepTile(
            nomor: '4',
            judul: 'Run / Reload',
            detail: 'Tekan R (hot restart) di terminal.',
          ),

          SizedBox(height: 24),
          _SectionTitle('Kapan Pakai Apa?'),
          _InfoRow('r', 'Hot reload — ubah teks, warna, layout'),
          _InfoRow('R', 'Hot restart — tambah file/import/route'),
          _InfoRow('q', 'Keluar dari flutter run'),
          _InfoRow('flutter run', 'Kalau ubah pubspec.yaml / nambah package'),

          SizedBox(height: 24),
          _SectionTitle('Struktur Folder'),
          _CodeBlock(
            'lib/\n'
            '├── main.dart\n'
            '├── app.dart\n'
            '├── dashboard.dart\n'
            '├── pages/\n'
            '│   ├── home_page.dart\n'
            '│   ├── materi_page.dart\n'
            '│   ├── profile_page.dart\n'
            '│   └── pertemuan/\n'
            '│       ├── p1_page.dart\n'
            '│       ├── p2_page.dart\n'
            '│       ├── p3_listview.dart\n'
            '│       └── p4_page.dart\n',
          ),

          SizedBox(height: 24),
          _SectionTitle('Konsistensi Nama'),
          _InfoRow('File', 'snake_case — p4_page.dart'),
          _InfoRow('Class', 'PascalCase — P4Page'),
          _InfoRow('Route', "pendek — '/p4'"),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String nomor;
  final String judul;
  final String detail;
  const _StepTile({
    required this.nomor,
    required this.judul,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blueAccent,
              child: Text(
                nomor,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String kiri;
  final String kanan;
  const _InfoRow(this.kiri, this.kanan);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              kiri,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(kanan)),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String text;
  const _CodeBlock(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }
}
