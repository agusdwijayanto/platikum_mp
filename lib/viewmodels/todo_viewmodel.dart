import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo_model.dart';

const String supabaseUrl = 'https://abateiobysegtdgklnwi.supabase.co';
const String supabaseAnonKey = 'sb_publishable_cuTjsQsW3gihnDZJOD_FzA_nN253Ezc';

class TodoViewModel extends ChangeNotifier {
  List<Todo> _daftarTugas = [];
  bool _sedangMuat = true;
  String? _pesanError;

  final TextEditingController judulController = TextEditingController();

  List<Todo> get daftarTugas => _daftarTugas;
  bool get sedangMuat => _sedangMuat;
  String? get pesanError => _pesanError;

  Session? get _sesi => Supabase.instance.client.auth.currentSession;
  User? get _pengguna => Supabase.instance.client.auth.currentUser;

  Map<String, String> _header() {
    return {
      'apikey': supabaseAnonKey,
      'Authorization': 'Bearer ${_sesi?.accessToken ?? supabaseAnonKey}',
      'Content-Type': 'application/json',
    };
  }

  String get _alamatTodos => '$supabaseUrl/rest/v1/todos';

  @override
  void dispose() {
    judulController.dispose();
    super.dispose();
  }

  Future<void> ambilTugas() async {
    if (_pengguna == null) {
      _sedangMuat = false;
      _pesanError = 'Belum ada sesi login. Silakan login dulu.';
      notifyListeners();
      return;
    }
    _sedangMuat = true;
    _pesanError = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_alamatTodos?select=*&order=id.asc'),
        headers: _header(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        _daftarTugas = decoded.map((item) => Todo.fromJson(item)).toList();
        _sedangMuat = false;
      } else {
        _pesanError = 'Gagal mengambil data (${response.statusCode}): ${response.body}';
        _sedangMuat = false;
      }
    } catch (e) {
      _pesanError = 'Tidak bisa terhubung ke server: $e';
      _sedangMuat = false;
    }
    notifyListeners();
  }

  Future<bool> tambahTugas() async {
    final judul = judulController.text.trim();
    if (judul.isEmpty || _pengguna == null) return false;
    try {
      final response = await http.post(
        Uri.parse(_alamatTodos),
        headers: _header(),
        body: jsonEncode({'judul': judul, 'user_id': _pengguna!.id}),
      );
      if (response.statusCode == 201) {
        judulController.clear();
        ambilTugas();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> ubahStatusTugas(Todo tugas, bool selesai) async {
    try {
      final response = await http.patch(
        Uri.parse('$_alamatTodos?id=eq.${tugas.id}'),
        headers: _header(),
        body: jsonEncode({'selesai': selesai}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        ambilTugas();
      }
    } catch (_) {}
  }

  Future<bool> hapusTugas(Todo tugas) async {
    try {
      final response = await http.delete(
        Uri.parse('$_alamatTodos?id=eq.${tugas.id}'),
        headers: _header(),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        ambilTugas();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
