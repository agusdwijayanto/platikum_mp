import 'package:flutter/material.dart';
import '../../models/todo_model.dart';
import '../../viewmodels/todo_viewmodel.dart';

class P8TodoPage extends StatefulWidget {
  const P8TodoPage({super.key});

  @override
  State<P8TodoPage> createState() => _P8TodoPageState();
}

class _P8TodoPageState extends State<P8TodoPage> {
  late final TodoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TodoViewModel();
    _viewModel.ambilTugas();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _tampilPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  void _dialogTambahTugas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: TextField(
          controller: _viewModel.judulController,
          decoration: const InputDecoration(
            labelText: 'Judul tugas',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final sukses = await _viewModel.tambahTugas();
              if (!mounted) return;
              Navigator.pop(context);
              if (sukses) {
                _tampilPesan('Tugas ditambahkan');
              } else {
                _tampilPesan('Gagal menambah tugas');
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _konfirmasiHapus(Todo tugas) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text('Hapus tugas "${tugas.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    final sukses = await _viewModel.hapusTugas(tugas);
    if (!mounted) return;
    if (sukses) {
      _tampilPesan('Tugas dihapus');
    } else {
      _tampilPesan('Gagal menghapus tugas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pertemuan 8 - To-Do List API'),
          ),
          body: _isiBody(),
          floatingActionButton: FloatingActionButton(
            onPressed: _dialogTambahTugas,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _isiBody() {
    if (_viewModel.sedangMuat) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.pesanError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_viewModel.pesanError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _viewModel.ambilTugas(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_viewModel.daftarTugas.isEmpty) {
      return const Center(child: Text('Belum ada tugas'));
    }
    return RefreshIndicator(
      onRefresh: () => _viewModel.ambilTugas(),
      child: ListView.builder(
        itemCount: _viewModel.daftarTugas.length,
        itemBuilder: (context, index) {
          final tugas = _viewModel.daftarTugas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Checkbox(
                value: tugas.selesai,
                onChanged: (value) => _viewModel.ubahStatusTugas(tugas, value ?? false),
              ),
              title: Text(
                tugas.judul,
                style: TextStyle(
                  decoration: tugas.selesai ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _konfirmasiHapus(tugas),
              ),
            ),
          );
        },
      ),
    );
  }
}
