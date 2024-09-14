// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pau_ybs_kitap_paylasim_tez/config/theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final Timestamp timeStamp;
  final String isSentByMe;
  final String user_nickname;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timeStamp,
    required this.isSentByMe,
    required this.user_nickname,
  });

  @override
  Widget build(BuildContext context) {
    DateTime datetime = timeStamp.toDate();
    String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(datetime);

    return Align(
      alignment: FirebaseAuth.instance.currentUser!.uid == isSentByMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: FirebaseAuth.instance.currentUser!.uid == isSentByMe
              ? AppColors.imagePickerUsageAppBarColor
              : Color.fromARGB(255, 132, 132, 132),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
            bottomLeft: Radius.circular(
                FirebaseAuth.instance.currentUser!.uid == isSentByMe ? 25 : 3),
            bottomRight: Radius.circular(
                FirebaseAuth.instance.currentUser!.uid == isSentByMe ? 3 : 25),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   alignment: Alignment.topLeft,
            //   child: Text(
            //     user_nickname,
            //     style: TextStyle(
            //         fontSize: 13,
            //         color: Colors.white,
            //         fontWeight: FontWeight.bold),
            //   ),
            // ),
            Text(
              message,
              style: TextStyle(
                  color: Colors.white, fontSize: 18, letterSpacing: 1.5),
            ),
            SizedBox(height: 5),
            Container(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedDate,
                style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
