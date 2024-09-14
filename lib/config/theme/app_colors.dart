//SAMPLE

import 'package:flutter/material.dart';

// Projede kullanilacak renkleri de bir dosyada tutarak tum projede kullandigimizda
// renklerde bir degisiklik oldugunda tum kodlarda degil sadece bu dosyada renk kodunu
// degistirmemiz yeterli olacaktir.
// Nesneleri static olarak yaparsak da AppColors.mainColor gibi parantezsiz olarak kullanabiliriz.

//Color.fromARGB(255, 217, 222, 238)
class AppColors {
  static const primary = Color(0xff40e0d0);
  static const background = Color(0xff1A2947);
  static const white = Colors.white;
  static const black = Color(0xff000000);
  static const generalBackground= Colors.white;//profil arka plan rengi
  static const imagePickerUsageBackgroundColor=Colors.white ;
  static const imagePickerUsageTextFieldColor=Colors.white;
  static const imagePickerUsageAppBarColor=Color(0xff000080);
  static const imagePickerUsageBottomAppBarColor=Color(0xff000080);
  //BottomAppbar İcon renkleri
  static const iconColor=Color.fromRGBO(253, 255, 255, 1);
  static const fosucIconColor=Color.fromARGB(255, 165, 146, 239);
  static const bottomIconBlack=Color.fromARGB(255, 25, 14, 14);
  static const grey= Colors.grey;
  //static const iconColor=Color.fromARGB(255, 204, 203, 203);
 // Color.fromARGB(255, 205, 162, 212)
  // 0xff0077be
  // Color(0xffffd700)
}