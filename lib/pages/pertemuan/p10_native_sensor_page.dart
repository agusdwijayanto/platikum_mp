import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class P10NativeSensorPage extends StatelessWidget {
  const P10NativeSensorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pertemuan 10 - Native dan Sensor'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.photo_camera), text: 'Kamera'),
              Tab(icon: Icon(Icons.my_location), text: 'Lokasi'),
              Tab(icon: Icon(Icons.notifications), text: 'Notifikasi'),
              Tab(icon: Icon(Icons.verified_user), text: 'Izin'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_TabKamera(), _TabLokasi(), _TabNotifikasi(), _TabIzin()],
        ),
      ),
    );
  }
}

class _TabKamera extends StatefulWidget {
  const _TabKamera();

  @override
  State<_TabKamera> createState() => _TabKameraState();
}

class _TabKameraState extends State<_TabKamera> {
  File? _foto;
  String _pesan = 'Belum ada foto.';

  Future<void> _ambilFoto() async {
    final izin = await Permission.camera.request();
    if (!izin.isGranted) {
      setState(() => _pesan = 'Izin kamera tidak diberikan.');
      return;
    }
    final hasil = await ImagePicker().pickImage(source: ImageSource.camera);
    if (hasil == null) return;
    setState(() {
      _foto = File(hasil.path);
      _pesan = 'Foto berhasil diambil.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: _ambilFoto,
          icon: const Icon(Icons.photo_camera),
          label: const Text('Ambil Foto'),
        ),
        const SizedBox(height: 16),
        Text(_pesan),
        if (_foto != null) ...[
          const SizedBox(height: 12),
          Image.file(_foto!),
        ],
      ],
    );
  }
}

class _TabLokasi extends StatefulWidget {
  const _TabLokasi();

  @override
  State<_TabLokasi> createState() => _TabLokasiState();
}

class _TabLokasiState extends State<_TabLokasi> {
  Position? _posisi;
  String _pesan = 'Tekan tombol untuk mengambil lokasi saat ini.';
  bool _memproses = false;

  Future<void> _ambilLokasi() async {
    setState(() => _memproses = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(
          () => _pesan = 'Layanan lokasi belum aktif. Aktifkan GPS dulu.',
        );
        return;
      }
      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.denied ||
          izin == LocationPermission.deniedForever) {
        setState(() => _pesan = 'Izin lokasi tidak diberikan.');
        return;
      }
      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      setState(() {
        _posisi = posisi;
        _pesan = 'Lokasi berhasil diambil.';
      });
    } catch (e) {
      setState(() => _pesan = 'Gagal mengambil lokasi: $e');
    } finally {
      setState(() => _memproses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: _memproses ? null : _ambilLokasi,
          icon: const Icon(Icons.my_location),
          label: const Text('Ambil Lokasi'),
        ),
        const SizedBox(height: 16),
        if (_memproses)
          const Center(child: CircularProgressIndicator())
        else
          Text(_pesan),
        if (_posisi != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latitude: ${_posisi!.latitude.toStringAsFixed(6)}'),
                  Text('Longitude: ${_posisi!.longitude.toStringAsFixed(6)}'),
                  Text('Akurasi: ${_posisi!.accuracy.toStringAsFixed(1)} meter'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TabNotifikasi extends StatefulWidget {
  const _TabNotifikasi();

  @override
  State<_TabNotifikasi> createState() => _TabNotifikasiState();
}

class _TabNotifikasiState extends State<_TabNotifikasi> {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  String _pesan = 'Tekan tombol untuk menampilkan notifikasi.';
  bool _siap = false;

  @override
  void initState() {
    super.initState();
    _inisialisasi();
  }

  Future<void> _inisialisasi() async {
    const pengaturan = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: pengaturan);
    _siap = true;
  }

  Future<void> _tampilkanNotifikasi() async {
    final izin = await Permission.notification.request();
    if (!izin.isGranted) {
      setState(() => _pesan = 'Izin notifikasi tidak diberikan.');
      return;
    }
    if (!_siap) await _inisialisasi();
    await _plugin.show(
      id: 0,
      title: 'Pertemuan 10 - Native dan Sensor',
      body: 'Notifikasi lokal berhasil ditampilkan.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'p10_notifikasi',
          'Notifikasi Pertemuan 10',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
    setState(() => _pesan = 'Notifikasi dikirim. Periksa panel notifikasi HP.');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: _tampilkanNotifikasi,
          icon: const Icon(Icons.notifications),
          label: const Text('Tampilkan Notifikasi'),
        ),
        const SizedBox(height: 16),
        Text(_pesan),
      ],
    );
  }
}

class _TabIzin extends StatefulWidget {
  const _TabIzin();

  @override
  State<_TabIzin> createState() => _TabIzinState();
}

class _TabIzinState extends State<_TabIzin> with WidgetsBindingObserver {
  static const _daftarIzin = [
    (nama: 'Kamera', ikon: Icons.photo_camera, izin: Permission.camera),
    (
      nama: 'Lokasi',
      ikon: Icons.my_location,
      izin: Permission.locationWhenInUse,
    ),
    (
      nama: 'Notifikasi',
      ikon: Icons.notifications,
      izin: Permission.notification,
    ),
  ];

  final Map<Permission, PermissionStatus> _status = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _muatStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Status dibaca ulang sesudah kembali dari Pengaturan, karena izin
  // bisa berubah di luar aplikasi.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _muatStatus();
  }

  Future<void> _muatStatus() async {
    final hasil = <Permission, PermissionStatus>{};
    for (final item in _daftarIzin) {
      hasil[item.izin] = await item.izin.status;
    }
    if (!mounted) return;
    setState(() {
      _status
        ..clear()
        ..addAll(hasil);
    });
  }

  Future<void> _mintaIzin(Permission izin) async {
    final status = await izin.request();
    if (status.isPermanentlyDenied) await openAppSettings();
    _muatStatus();
  }

  String _teksStatus(PermissionStatus? status) {
    if (status == null) return 'Memuat...';
    if (status.isGranted) return 'Diizinkan';
    if (status.isPermanentlyDenied) {
      return 'Ditolak permanen, ubah lewat Pengaturan';
    }
    if (status.isDenied) return 'Belum diizinkan';
    if (status.isRestricted) return 'Dibatasi sistem';
    if (status.isLimited) return 'Terbatas';
    return status.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final item in _daftarIzin)
          Card(
            child: ListTile(
              leading: Icon(item.ikon),
              title: Text(item.nama),
              subtitle: Text(_teksStatus(_status[item.izin])),
              trailing: TextButton(
                onPressed: () => _mintaIzin(item.izin),
                child: const Text('Minta Izin'),
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: openAppSettings,
          icon: const Icon(Icons.settings),
          label: const Text('Buka Pengaturan Aplikasi'),
        ),
      ],
    );
  }
}
