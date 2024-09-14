import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Veri sınıfı
class MyData {
  String? email;
  String? password;
  XFile? data1;
  XFile? data2;

  MyData(
      {required this.data1,
      required this.data2,
      required this.email,
      required this.password});
}

// Veri sağlayıcısı sınıfı
class DataProvider with ChangeNotifier {
  MyData _myData = MyData(data1: null, data2: null, email: '', password: '');

  MyData get myData => _myData;

  void updateData(
      XFile? newData1, XFile? newData2, String email, String password) {
    _myData = MyData(
        data1: newData1, data2: newData2, email: email, password: password);
    notifyListeners();
  }
}
