// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
//texteditingcontroller => kullanıcının girdiği inputlara erişimimizi sağlar.
class CustomTextfield extends StatelessWidget {
  final double horizontalValue;
  final double verticalValue;
  final double borderRadiusValue;
  final String labelTextValue;
  final bool obscureTextValue;
  final TextEditingController fieldController;
  final double containerHeight;
  final int maxLines;
  final int maxLength;
  final Color color;

  const CustomTextfield({
    super.key,
    this.horizontalValue = 40,
    this.verticalValue = 18,
    this.borderRadiusValue = 18,
    this.labelTextValue = 'Text Sample',
    this.obscureTextValue = false,
    this.containerHeight = 60,
    required this.fieldController,
    this.maxLines = 1,
    this.maxLength = 30,
    this.color = Colors.white ,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      //Horizantal yatayda genişletiyor/daraltıyor, vertical yukarıdan boşluk bırakıyor.
      padding: EdgeInsets.symmetric(
        horizontal: horizontalValue, //40
        vertical: verticalValue, //18
      ),
      //Dekorasyon textfield yerine container üzerinde yapıldı.
      child: Container(
        height: containerHeight,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 217, 222, 238),
          // border: Border.all(
          //   width: 1,
          //   color: Colors.black,
          // ),
          //borderRadius Containerin koşelerini yuvarlar.
          borderRadius: BorderRadius.circular(borderRadiusValue), //18
        ),
        //Padding kısmında EdgeInsets.only() sadece tek bir taraftan padding vermemizi sağlar.
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
            child: TextFormField(
              maxLines: maxLines,
              maxLength: maxLength,
              controller: fieldController,
              obscureText: obscureTextValue,
              decoration: InputDecoration(
                labelText: labelTextValue, //e-mail, şifre vs.
                counterText: '',
                //hintText: labelTextValue,
                contentPadding: EdgeInsets.all(5),
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
