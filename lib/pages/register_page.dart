import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Registrasi akun Supabase. Email dan password menjadi kredensial
// login; data lainnya disimpan sebagai metadata akun dan dibaca
// oleh halaman Profil.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nimController = TextEditingController();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final hpController = TextEditingController();
  final passController = TextEditingController();

  String? jenisKelamin;
  bool membaca = false;
  bool olahraga = false;
  bool musik = false;
  bool _memproses = false;

  @override
  void dispose() {
    nimController.dispose();
    namaController.dispose();
    emailController.dispose();
    hpController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final hobi = <String>[];
    if (membaca) hobi.add('Membaca');
    if (olahraga) hobi.add('Olahraga');
    if (musik) hobi.add('Musik');

    setState(() => _memproses = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passController.text,
        data: {
          'nim': nimController.text.trim(),
          'nama': namaController.text.trim(),
          'no_hp': hpController.text.trim(),
          if (jenisKelamin != null) 'jenis_kelamin': jenisKelamin,
          'hobi': hobi.join(', '),
        },
      );
      if (!mounted) return;
      // Session kosong berarti server menunggu konfirmasi email.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.session == null
                ? 'Registrasi berhasil. Cek email untuk konfirmasi, lalu login.'
                : 'Registrasi berhasil',
          ),
        ),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi gagal: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa terhubung ke server: $e')),
      );
    } finally {
      if (mounted) setState(() => _memproses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nimController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NIM',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'NIM wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: hpController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor HP',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Nomor HP wajib diisi'
                  : null,
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
            const SizedBox(height: 16),
            TextFormField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _memproses ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('DAFTAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
