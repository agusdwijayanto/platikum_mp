import 'package:flutter/material.dart';

class P6_FormPage extends StatefulWidget {
  const P6_FormPage({super.key});

  @override
  State<P6_FormPage> createState() => _P6_FormPageState();
}

class _P6_FormPageState extends State<P6_FormPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final emailController = TextEditingController();

  String? jenisKelamin;
  bool membaca = false;
  bool olahraga = false;
  bool musik = false;
  bool mancing = false;

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void simpanData() {
    if (!_formKey.currentState!.validate()) {
      return; // berhenti kalau ada yang tidak valid
    }

    final hobi = <String>[];
    if (membaca) hobi.add('Membaca');
    if (olahraga) hobi.add('Olahraga');
    if (musik) hobi.add('Musik');
    if (mancing) hobi.add('Mancing');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Mahasiswa'),
        content: Text(
          'Nama: ${namaController.text}\n'
          'Email: ${emailController.text}\n'
          'Jenis Kelamin: ${jenisKelamin ?? '-'}\n'
          'Hobi: ${hobi.isEmpty ? '-' : hobi.join(', ')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Mahasiswa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Jenis Kelamin'),
            RadioListTile<String>(
              title: const Text('Laki-laki'),
              value: 'Laki-laki',
              groupValue: jenisKelamin,
              onChanged: (value) {
                setState(() {
                  jenisKelamin = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Perempuan'),
              value: 'Perempuan',
              groupValue: jenisKelamin,
              onChanged: (value) {
                setState(() {
                  jenisKelamin = value;
                });
              },
            ),
            const SizedBox(height: 8),
            const Text('Hobi'),
            CheckboxListTile(
              title: const Text('Membaca'),
              value: membaca,
              onChanged: (value) {
                setState(() {
                  membaca = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Olahraga'),
              value: olahraga,
              onChanged: (value) {
                setState(() {
                  olahraga = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Musik'),
              value: musik,
              onChanged: (value) {
                setState(() {
                  musik = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Mancing'),
              value: mancing,
              onChanged: (value) {
                setState(() {
                  mancing = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: simpanData,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
