// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/add_books.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';
import '../../config/theme/app_colors.dart';
import 'profile_pages/profile_page.dart';

class emptyBookListPage extends StatelessWidget {
  final String? comingUserID;
  const emptyBookListPage({super.key, this.comingUserID});

  @override
  Widget build(BuildContext context) {
    if (comingUserID == null) {
      return Scaffold(
        extendBody: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ProfilePage(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          title: const Text(
            'Kitap Yok!',
            style: TextStyle(
                color: AppColors.white,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 23,
                letterSpacing: 1),
          ),
          elevation: 20,
          backgroundColor: AppColors.imagePickerUsageAppBarColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/icons/empty_folder.png',
                height: 300,
                width: 300,
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.5,
                        indent: 40,
                        endIndent: 40,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Henüz Eklenmiş Kitabınız Bulunmuyor.  Kitap Eklemek İster Misiniz?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ImagePickerUsage(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(150, 43),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Kitap Ekle',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(),
      );
    } else {
      return Scaffold(
        extendBody: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ProfilePage(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          title: const Text(
            'Kitap Yok!',
            style: TextStyle(
                color: AppColors.white,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 23,
                letterSpacing: 1),
          ),
          elevation: 20,
          backgroundColor: AppColors.imagePickerUsageAppBarColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/icons/empty_folder.png',
                height: 300,
                width: 300,
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.5,
                        indent: 40,
                        endIndent: 40,
                      ),
                    ),
                  ],
                )),
              ),
              Text(
                'Paylaşılan kitap yok.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(),
      );
    }
  }
}
