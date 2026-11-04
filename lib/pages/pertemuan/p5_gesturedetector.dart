import 'package:flutter/material.dart';

class P5Gesturedetector extends StatefulWidget {
  const P5Gesturedetector({super.key});

  @override
  State<P5Gesturedetector> createState() => _P5GesturedetectorState();
}

class _P5GesturedetectorState extends State<P5Gesturedetector> {
  int _tapCount = 0;
  int _doubleTapCount = 0;
  bool _lampuNyala = false;
  Color _warnaKotak = Colors.blue; // warna awal

  void _onTap() {
    setState(() {
      _tapCount++;
      _lampuNyala = false;
      _warnaKotak = Colors.green; // tap 1x -> hijau
    });
  }

  void _onDoubleTap() {
    setState(() {
      _doubleTapCount++;
      _lampuNyala = false;
      _warnaKotak = Colors.purple; // tap 2x -> ungu
    });
  }

  void _onLongPress() {
    setState(() {
      _lampuNyala = !_lampuNyala;
      if (!_lampuNyala) _warnaKotak = Colors.blue; // lampu mati -> balik biru
    });
  }

  // Helper baris info di dalam tombol
  Widget _barisInfo(String label, String nilai, Color warnaTeks) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: warnaTeks,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            nilai,
            style: TextStyle(
              color: warnaTeks,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final warnaBox = _lampuNyala ? Colors.yellow : _warnaKotak;
    final warnaTeks = _lampuNyala ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratikum P5 - GestureDetector'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SATU tombol di tengah: tap 1x, tap 2x, tahan lama
              GestureDetector(
                onTap: _onTap,
                onDoubleTap: _onDoubleTap,
                onLongPress: _onLongPress,
                child: Container(
                  width: 240,
                  height: 280,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: warnaBox,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: warnaBox.withOpacity(0.5),
                        blurRadius: _lampuNyala ? 30 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _lampuNyala ? Icons.lightbulb : Icons.touch_app,
                        color: warnaTeks,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      _barisInfo('TAP 1x', '$_tapCount', warnaTeks),
                      _barisInfo('TAP 2x', '$_doubleTapCount', warnaTeks),
                      _barisInfo(
                        'LAMPU',
                        _lampuNyala ? 'NYALA' : 'MATI',
                        warnaTeks,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Tap 1x = hijau, tap 2x = ungu, tahan lama = lampu kuning',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),

              const SizedBox(height: 30),

              // Info total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total Tap: ${_tapCount + _doubleTapCount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
