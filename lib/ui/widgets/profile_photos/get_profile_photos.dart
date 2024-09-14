// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

class GetProfilePhotos extends StatefulWidget {
  final String profileImagePath;
  final String coverImagePath;

  const GetProfilePhotos(
      {super.key,
      required this.profileImagePath,
      required this.coverImagePath});

  @override
  // ignore: no_logic_in_create_state
  State<GetProfilePhotos> createState() => _GetProfilePhotosState(
      profileImagePath: profileImagePath, coverImagePath: coverImagePath);
}

class _GetProfilePhotosState extends State<GetProfilePhotos> {
  //Profil sayfasında fotoğraf çekmek için fotoğrafların firebase yollarını tutan değişkenler
  String profileImagePath;
  String coverImagePath;

  _GetProfilePhotosState({
    required this.profileImagePath,
    required this.coverImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.generalBackground,
      //resizeToAvoidBottomInset widgetların yukarı kaymasını engeller
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Stack(
            children: [
              //Kapak Fotoğrafı Alanı
              Container(
                //top:48
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                height: screenHeight * 0.28,
                width: screenWidth,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.generalBackground, width: 0.8),
                  image: DecorationImage(
                    alignment: const Alignment(-2, -0.55),
                    image: NetworkImage(coverImagePath),
                    fit: BoxFit.cover,
                  ),
                  color: AppColors.generalBackground,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                ),
              ),
              //Profil fotoğrafı
              Padding(
                //top:175
                padding: const EdgeInsets.only(top: 140),
                child: Center(
                  child: CircleAvatar(
                    radius: 61,
                    backgroundColor: AppColors.generalBackground,
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: AppColors.generalBackground,
                      backgroundImage: NetworkImage(profileImagePath),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
