# Pertemuan 11 — Implementasi Arsitektur MVVM

Nama: Agus Dwijayanto
NIM: 241011750001
Kelas: 04SIFE002

## 1. Bagaimana cara menerapkan arsitektur MVVM pada aplikasi yang dibuat

Pada pertemuan ini saya menerapkan arsitektur MVVM pada fitur To-Do List
(Pertemuan 8) dengan memisahkan kode menjadi tiga lapis:

- **Model** (`lib/models/todo_model.dart`): kelas `Todo` menyimpan struktur
  data (id, judul, selesai, user_id) dengan `fromJson` dan `toJson`.
- **ViewModel** (`lib/viewmodels/todo_viewmodel.dart`): kelas `TodoViewModel`
  extends `ChangeNotifier`, menyimpan state (daftarTugas, sedangMuat,
  pesanError) dan logika CRUD (muatTugas, tambahTugas, ubahStatusTugas,
  hapusTugas). Pemanggilan Supabase memakai header apikey dan Authorization
  Bearer token sesi serta user_id.
- **View** (`lib/pages/pertemuan/p8_todo_page.dart`): `P8TodoPage` hanya
  menampilkan UI dan meneruskan aksi pengguna ke ViewModel, mendengarkan
  perubahan lewat `ListenableBuilder`. Route `/p8` dan kartu Materi tidak
  diubah.

Alur datanya: View memanggil ViewModel, ViewModel memanggil Supabase,
hasilnya disimpan di state ViewModel, lalu View ikut berubah lewat
`notifyListeners`. Tidak ada package baru yang ditambahkan.

## 2. Contoh implementasi langsung

Model:

```dart
class Todo {
  final int id;
  final String judul;
  final bool selesai;
  final String userId;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      judul: json['judul'] ?? '',
      selesai: json['selesai'] == true,
      userId: json['user_id'] ?? '',
    );
  }
}
```

ViewModel:

```dart
class TodoViewModel extends ChangeNotifier {
  List<Todo> _daftarTugas = [];
  bool _sedangMuat = true;
  String? _pesanError;

  final TextEditingController judulController = TextEditingController();

  Future<void> ambilTugas() async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/todos?select=*&order=id.asc'),
      headers: _header(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      _daftarTugas = decoded.map((item) => Todo.fromJson(item)).toList();
      _sedangMuat = false;
    }
    notifyListeners();
  }
}
```

View:

```dart
class _P8TodoPageState extends State<P8TodoPage> {
  late final TodoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TodoViewModel();
    _viewModel.ambilTugas();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pertemuan 8 - To-Do List API')),
          body: _isiBody(),
        );
      },
    );
  }
}
```

## 3. Hasil

Halaman To-Do berjalan sesudah refactor, tugas tampil dan tombol tambah,
centang, hapus berfungsi.

![Halaman To-Do sesudah refactor](hasil-todo-di-hp.jpg)

Struktur file tiga lapis (models, viewmodels, halaman P8):

![Struktur file tiga lapis](struktur-file-mvvm.png)

Pengujian di HP Poco F6: login, tambah, centang, hapus, logout, dan dua akun
tetap hanya melihat tugas masing-masing, sama seperti sebelum refactor.
