// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:pau_ybs_kitap_paylasim_tez/config/theme/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final String userNameSurname;
  final String userNickname;
  final String userProfileImagePath;
  final String review;
  final String reviewImagePath;
  final String timestamp;

  const ReviewCard(
      {super.key,
      required this.userNameSurname,
      required this.userNickname,
      required this.review,
      required this.reviewImagePath,
      required this.userProfileImagePath,
      required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      shadowColor: AppColors.imagePickerUsageAppBarColor,
      elevation: 15,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar, İsim ve Kullanıcı Adı
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    backgroundImage:
                        NetworkImage(userProfileImagePath), // Avatar resmi
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userNameSurname,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      userNickname,
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(
              color: Color(0xFF757575),
              thickness: 0.5,
              indent: 5,
              endIndent: 5,
            ),
            SizedBox(height: 10),
            // Tweet Metni
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                review,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            // Tweet Fotoğrafı
            Image.network(
              reviewImagePath,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            // Tarih
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timestamp,
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
