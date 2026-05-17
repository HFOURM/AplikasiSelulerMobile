import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _nameController = TextEditingController();

  // State Management yang jauh lebih efisien & intuitif tanpa form keyboard
  bool _isMale = true;
  int _height = 170;
  int _weight = 65;
  int _age = 25;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Kalkulasi dinamis yang selalu valid (Menghindari Infinity & NaN)
  double get _bmi {
    if (_height == 0) return 0;
    return _weight / ((_height / 100) * (_height / 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // Latar belakang abu-abu kebiruan yang modern
      appBar: AppBar(
        title: const Text(
          "Kalkulator BMI",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1D1E33),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Input Nama (Opsional)
              _buildNameField(),
              const SizedBox(height: 8),

              // 2. Pemilihan Gender (Interactive Cards)
              Row(
                children: [
                  _buildGenderCard("LAKI-LAKI", Icons.male, _isMale, () {
                    setState(() => _isMale = true);
                  }),
                  _buildGenderCard("PEREMPUAN", Icons.female, !_isMale, () {
                    setState(() => _isMale = false);
                  }),
                ],
              ),
              const SizedBox(height: 8),

              // 3. Slider Tinggi Badan
              _buildHeightCard(),
              const SizedBox(height: 8),

              // 4. Counter Berat & Usia
              Row(
                children: [
                  _buildCounterCard("BERAT", _weight, "kg", () {
                    if (_weight > 10) setState(() => _weight--);
                  }, () {
                    if (_weight < 300) setState(() => _weight++);
                  }),
                  _buildCounterCard("USIA", _age, "thn", () {
                    if (_age > 1) setState(() => _age--);
                  }, () {
                    if (_age < 120) setState(() => _age++);
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Hasil Kalkulasi Dinamis (Selalu tampil di bawah)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                // Menggunakan ValueKey berdasarkan BMI agar transisi animasi aktif saat kategori berubah
                child: _buildResultCard(key: ValueKey<String>(_getCategory(_bmi))),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- KOMPONEN UI ---

  Widget _buildNameField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: TextField(
        controller: _nameController,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1D1E33)),
        decoration: InputDecoration(
          hintText: "Nama Lengkap (Opsional)",
          hintStyle: const TextStyle(color: Colors.black26),
          prefixIcon: const Icon(Icons.person_outline, color: Colors.black26),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildGenderCard(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5C6BC0).withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF5C6BC0) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 56, color: isSelected ? const Color(0xFF5C6BC0) : Colors.black26),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: isSelected ? const Color(0xFF5C6BC0) : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeightCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          const Text(
            "TINGGI BADAN",
            style: TextStyle(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _height.toString(),
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF1D1E33)),
              ),
              const Text(" cm", style: TextStyle(fontSize: 18, color: Colors.black38, fontWeight: FontWeight.bold)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF5C6BC0),
              inactiveTrackColor: const Color(0xFF5C6BC0).withOpacity(0.15),
              thumbColor: const Color(0xFF5C6BC0),
              overlayColor: const Color(0xFF5C6BC0).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
              trackHeight: 6,
            ),
            child: Slider(
              value: _height.toDouble(),
              min: 100,
              max: 230,
              onChanged: (double newValue) {
                setState(() {
                  _height = newValue.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterCard(String title, int value, String unit, VoidCallback onMinus, VoidCallback onPlus) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF1D1E33)),
                ),
                if (unit.isNotEmpty) 
                  Text(" $unit", style: const TextStyle(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRoundButton(Icons.remove, onMinus),
                const SizedBox(width: 16),
                _buildRoundButton(Icons.add, onPlus),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: const Color(0xFF5C6BC0).withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        splashColor: const Color(0xFF5C6BC0).withOpacity(0.3),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: const Color(0xFF5C6BC0), size: 28),
        ),
      ),
    );
  }

  String _getCategory(double bmi) {
    if (bmi < 18.5) return "Kurus";
    if (bmi < 23.0) return "Normal";
    if (bmi < 25.0) return "Overweight";
    return "Obesitas";
  }

  Widget _buildResultCard({Key? key}) {
    final bmi = _bmi;
    String category;
    Color categoryColor;
    String advice;

    // Logika Asia-Pasifik (Telah disempurnakan)
    if (bmi < 18.5) {
      category = "Kurus";
      categoryColor = const Color(0xFF00B0FF); // Light Blue
      advice = "Anda kekurangan berat badan. Tingkatkan asupan makanan bergizi.";
    } else if (bmi < 23.0) {
      category = "Normal";
      categoryColor = const Color(0xFF00E676); // Vibrant Green
      advice = "Sempurna! Berat badan Anda berada di rentang ideal.";
    } else if (bmi < 25.0) {
      category = "Kelebihan Berat";
      categoryColor = const Color(0xFFFF9100); // Vibrant Orange
      advice = "Kurangi asupan gula dan perbanyak aktivitas fisik harian.";
    } else {
      category = "Obesitas";
      categoryColor = const Color(0xFFFF1744); // Red
      advice = "Peringatan kesehatan. Disarankan untuk berkonsultasi dengan dokter.";
    }

    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: categoryColor.withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Text(
            "HASIL BMI",
            style: TextStyle(fontSize: 14, color: categoryColor.withOpacity(0.8), fontWeight: FontWeight.w800, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: categoryColor, height: 1.0),
          ),
          const SizedBox(height: 8),
          Text(
            category.toUpperCase(),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: categoryColor, letterSpacing: 1),
          ),
          const SizedBox(height: 32),
          _buildDynamicProgressBar(bmi),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: categoryColor, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    advice,
                    style: TextStyle(
                      color: categoryColor.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDynamicProgressBar(double bmi) {
    double position = 0.0;
    if (bmi < 10.0) {
      position = 0.0;
    } else if (bmi >= 40.0) {
      position = 1.0;
    } else if (bmi < 18.5) {
      position = ((bmi - 10.0) / (18.5 - 10.0)) * 0.25;
    } else if (bmi < 23.0) {
      position = 0.25 + ((bmi - 18.5) / (23.0 - 18.5)) * 0.25;
    } else if (bmi < 25.0) {
      position = 0.50 + ((bmi - 23.0) / (25.0 - 23.0)) * 0.25;
    } else {
      position = 0.75 + ((bmi - 25.0) / (40.0 - 25.0)) * 0.25;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final markerPosition = position * width;

        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Multi-color Progress Bar Base (Rounded Pill)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Expanded(child: Container(height: 16, color: const Color(0xFF00B0FF))),
                      Expanded(child: Container(height: 16, color: const Color(0xFF00E676))),
                      Expanded(child: Container(height: 16, color: const Color(0xFFFF9100))),
                      Expanded(child: Container(height: 16, color: const Color(0xFFFF1744))),
                    ],
                  ),
                ),
                // Tooltip di atas marker
                Positioned(
                  left: (markerPosition - 20).clamp(0.0, width - 40.0), 
                  top: -32,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1E33),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                        ),
                        child: Text(
                          bmi.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Segitiga ke bawah sederhana menggunakan Container miring
                      Transform.translate(
                        offset: const Offset(0, -2),
                        child: RotationTransition(
                          turns: const AlwaysStoppedAnimation(45 / 360),
                          child: Container(width: 8, height: 8, color: const Color(0xFF1D1E33)),
                        ),
                      )
                    ],
                  ),
                ),
                // Marker Ring
                Positioned(
                  left: markerPosition - 10,
                  top: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1D1E33), width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                const SizedBox(height: 16, width: double.infinity),
                Positioned(left: width * 0.25 - 14, child: const Text("18.5", style: TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.bold))),
                Positioned(left: width * 0.50 - 14, child: const Text("23.0", style: TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.bold))),
                Positioned(left: width * 0.75 - 14, child: const Text("25.0", style: TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.bold))),
              ],
            )
          ],
        );
      },
    );
  }
}
