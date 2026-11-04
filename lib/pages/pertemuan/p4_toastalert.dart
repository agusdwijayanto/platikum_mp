import 'package:flutter/material.dart';

class P4ToastAlert extends StatelessWidget {
  const P4ToastAlert({super.key});

  // Data menu + icon — min 3 sesuai tugas
  static const _menus = [
    {'nama': 'Ayam Goreng Crispy', 'icon': Icons.fastfood},
    {'nama': 'Burger Keju Spesial', 'icon': Icons.lunch_dining},
    {'nama': 'Kentang Goreng', 'icon': Icons.takeout_dining},
    {'nama': 'Pizza Pepperoni', 'icon': Icons.local_pizza},
    {'nama': 'Es Teh Manis', 'icon': Icons.local_drink},
  ];

  void _showWelcome(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selamat datang pada aplikasi ini!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Alternatif toast package: Fluttertoast.showToast(msg: "Selamat datang pada aplikasi ini!");
  }

  void _showConfirm(BuildContext context, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pilihan'),
        content: Text('Apakah Anda memilih $nama?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ya, Anda memilih $nama')),
              );
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertemuan 4 - Menu Makanan'),
        backgroundColor: Colors.blueAccent,
      ),
      // Column sebagai layout utama — sesuai tugas
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Judul tebal + tappable -> toast
          GestureDetector(
            onTap: () => _showWelcome(context),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              color: Colors.blueAccent.withOpacity(0.08),
              child: Column(
                children: [
                  const Text(
                    'Daftar Menu Makanan Siap Saji',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap judul untuk info',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showWelcome(context),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Tampilkan Pesan Selamat Datang'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // ListView di dalam Expanded agar Column tidak overflow
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _menus.length,
              itemBuilder: (context, index) {
                final item = _menus[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ListTile(
                    leading: Icon(item['icon'] as IconData, color: Colors.blueAccent),
                    title: Text(item['nama'] as String),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _showConfirm(context, item['nama'] as String),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
