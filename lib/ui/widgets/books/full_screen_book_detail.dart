import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme/app_colors.dart';

class FullScreenPage extends StatelessWidget {
  // Resmi parametre olarak almak
  FullScreenPage({
    required this.child,
    required this.bookName,
    required this.bookAuthor,
    required this.bookYear,
    required this.BookDescription,
    required this.bookAddTime,
  });

  final Widget child;
  final String bookName;
  final String bookAuthor;
  final String bookYear;
  final String BookDescription;
  final DateTime bookAddTime;

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('dd.MM.yyyy - HH:mm').format(bookAddTime);
    return Scaffold(
      extendBody: true,
       appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        //centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
         title: const Text(
          'Detaylı Bilgi',
          style: TextStyle(
              color: AppColors.white,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
              fontSize: 23,letterSpacing: 1),
        ),
        elevation: 20,
        backgroundColor: AppColors.imagePickerUsageAppBarColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 8, right: 8),
          child: InkWell(
            onTap: () {
              // Navigator.pop metodu ile önceki sayfaya dönme
              Navigator.pop(context);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  child: child,
                  // Resme tekrar tıklandığında çalışacak onTap fonksiyonu
                  onTap: () {
                    // Navigator.pop metodu ile önceki sayfaya dönme
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      'KİTAP ADI:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Flexible(
                        child:
                            Text('$bookName', style: TextStyle(fontSize: 16)))
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      'YAZAR:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Flexible(
                        child:
                            Text('$bookAuthor', style: TextStyle(fontSize: 16)))
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      'BASIM YILI:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('$bookYear', style: TextStyle(fontSize: 16))
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      'EKLENME TARİHİ:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('$formattedTime', style: TextStyle(fontSize: 16))
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KİTAP AÇIKLAMASI:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('$BookDescription', style: TextStyle(fontSize: 16))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
