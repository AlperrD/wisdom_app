import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final Function? onPressed;

  const CustomElevatedButton(
      {super.key, this.label = 'deneme', this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 85, 67, 139),
        minimumSize: Size(200, 43),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 177, 158, 233),
        ),
      ),
    );
  }
}
