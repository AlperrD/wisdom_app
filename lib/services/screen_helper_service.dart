import 'package:flutter/material.dart';

class ScreenSizer {
  final BuildContext context;
  late double _widthFactor;
  late double _heightFactor;

  ScreenSizer(this.context) {
    // Ekran boyutunu al
    Size screenSize = MediaQuery.of(context).size;

    // Ekran genişliğine göre faktörleri belirle
    if (screenSize.width < 600) {
      // Küçük ekranlar için
      _widthFactor = 0.8;
      _heightFactor = 0.8;
    } else if (screenSize.width < 1200) {
      // Orta ekranlar için
      _widthFactor = 0.85;
      _heightFactor = 0.85;
    } else {
      // Büyük ekranlar için
      _widthFactor = 0.9;
      _heightFactor = 0.9;
    }
  }

  // Genişlik değerini döndür
  double get width => MediaQuery.of(context).size.width * _widthFactor;

  // Yükseklik değerini döndür
  double get height => MediaQuery.of(context).size.height * _heightFactor;
}

// Kullanımı:
// ScreenSizer sizer = ScreenSizer(context);
// double width = sizer.width;
// double height = sizer.height;