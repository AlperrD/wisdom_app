// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pau_ybs_kitap_paylasim_tez/services/login_auth_controller_service.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/create_profile.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/profile_pages/user_review.dart';
import 'package:pau_ybs_kitap_paylasim_tez/services/get_profile_photos_service.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';
import '../../../config/theme/app_colors.dart';
import '../../../services/get_user_reviews_service.dart';
import '../empty_profile_books_page.dart';
import 'profile_favorite_books_page.dart';
import 'profile_sharing_books_page.dart';

class ProfilePage extends StatefulWidget {
  final String? comingUserID;

  const ProfilePage({super.key, this.comingUserID});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  String userName = '';
  String userSurname = '';
  String userNickname = '';
  String userEmail = '';
  String userAbout = '';
  String userProfileImagePath = '';
  String userCoverImagePath = '';
  String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  late List<QueryDocumentSnapshot> reviews;

  // veritabanından Future kullanmadan veri çekme fonksiyonu.
  getUserAbout() {
    if (widget.comingUserID == null) {
      FirebaseFirestore.instance
          .collection('kullaniciBilgileri')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((gelenveri) {
        setState(() {
          userName = gelenveri.data()!['user_name'];
          userSurname = gelenveri.data()!['user_surname'];
          userNickname = gelenveri.data()!['user_nickname'];
          userEmail = gelenveri.data()!['email'];
          userAbout = gelenveri.data()!['user_about'];
          userProfileImagePath = gelenveri.data()!['profile_image'];
          userCoverImagePath = gelenveri.data()!['cover_image'];
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection('kullaniciBilgileri')
          .doc(widget.comingUserID)
          .get()
          .then((gelenveri) {
        setState(() {
          userName = gelenveri.data()!['user_name'];
          userSurname = gelenveri.data()!['user_surname'];
          userNickname = gelenveri.data()!['user_nickname'];
          userEmail = gelenveri.data()!['email'];
          userAbout = gelenveri.data()!['user_about'];
          userProfileImagePath = gelenveri.data()!['profile_image'];
        });
      });
    }
  }

  //Veri çekme fonksiyonu
  Future<void> _fetchData(String value) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final QuerySnapshot snapshot;
    List<QueryDocumentSnapshot> books;

    //Veri tabanından tarihe göre yeniden eskiye sıralı şekilde veri çeker
    //https://www.youtube.com/watch?v=StL0_12nBkQ orderby sorunu bu şekilde halledildi silme not kalsın(ADEM)

    if (widget.comingUserID == null) {
      if (value == 'favorite_books') {
        snapshot = await firestore
            .collection('favorite_books')
            .orderBy('Upload Date', descending: true)
            .where('Person Who Added', isEqualTo: userId)
            .get();
      } else {
        snapshot = await firestore
            .collection('books')
            .orderBy('Upload Date', descending: true)
            .where('Person Who Added', isEqualTo: userId)
            .get();
      }

      //Alınan kitap verileri listeye atandı
      books = snapshot.docs;
    } else {
      if (value == 'favorite_books') {
        snapshot = await firestore
            .collection('favorite_books')
            .orderBy('Upload Date', descending: true)
            .where('Person Who Added', isEqualTo: widget.comingUserID)
            .get();
      } else {
        snapshot = await firestore
            .collection('books')
            .orderBy('Upload Date', descending: true)
            .where('Person Who Added', isEqualTo: widget.comingUserID)
            .get();
      }

      //Alınan kitap verileri listeye atandı
      books = snapshot.docs;
    }

    //Listenin boş olup olmama durumuna göre ilgili ekranlar gösterilir
    if (value == 'favorite_books') {
      if (books.isNotEmpty) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FavoriteBookListPage(
              books: books,
              comingUserID: widget.comingUserID,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      } else {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => emptyBookListPage(
              comingUserID: widget.comingUserID,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    } else {
      if (books.isNotEmpty) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => BookListPage(
              books: books,
              comingUserID: widget.comingUserID,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      } else {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => emptyBookListPage(
              comingUserID: widget.comingUserID,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserAbout();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    if (widget.comingUserID == null) {
      return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.generalBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Profilim',
            style: TextStyle(
                color: AppColors.white,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 23,
                letterSpacing: 1),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(Icons.menu_rounded, size: 37),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
            ),
          ],
          elevation: 20,
          backgroundColor: AppColors.imagePickerUsageAppBarColor,
        ),
        endDrawer: Drawer(
          backgroundColor: AppColors.imagePickerUsageAppBarColor,
          shadowColor: AppColors.imagePickerUsageAppBarColor,
          elevation: 50.0,
          width: screenWidth * 0.75,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          child: ListView(
            children: [
              SizedBox(
                height: screenHeight * 0.2,
              ),
              //Profil Bilgileri
              ListTile(
                leading: CircleAvatar(
                  radius: 27,
                  backgroundColor: AppColors.generalBackground,
                  backgroundImage: NetworkImage(userProfileImagePath),
                ),
                title: Text(
                  "$userName $userSurname",
                  style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: Colors.white),
                ),
                subtitle: Text(
                  userNickname,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      color: Colors.white),
                ),
              ),
              const Divider(
                color: Color(0xFF757575),
                thickness: .7,
                indent: 18,
                endIndent: 18,
              ),
              //Yönlendirilecek sayfalar
              //Paylaşım yapma
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const UserReview(),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  leading: SizedBox(
                    height: 34,
                    width: 34,
                    child: Icon(
                      Icons.post_add_rounded,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  title: Text(
                    "Gönderi Paylaş",
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: Colors.white),
                  ),
                ),
              ),
              //Hesap bilgileri güncelleme
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => CreateProfile(
                          comingCurrentUserID: currentUserID,
                          currentUserProfileImage: userProfileImagePath,
                          currentUserCoverImage: userCoverImagePath,
                          currentUserName: userName,
                          currentUserSurname: userSurname,
                          currentUserNickName: userNickname,
                          currentUserAbout: userAbout,
                        ),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  leading: SizedBox(
                    height: 34,
                    width: 34,
                    child: Icon(
                      Icons.manage_accounts_rounded,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  title: Text(
                    "Profil Güncelleme",
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: Colors.white),
                  ),
                ),
              ),
              //Çıkış yapma
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => LoginController(),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  leading: SizedBox(
                    height: 34,
                    width: 34,
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  title: Text(
                    "Çıkış",
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.38,
                width: screenWidth,
                //PROFİL FOTO
                child: GetPhotosService(
                  comingUserID: widget.comingUserID,
                ),
              ),

              //isim
              Text(
                ('$userName $userSurname'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1,
                ),
              ),

              //nickname
              Text(
                (userNickname),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF757575),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              //hakkında
              SizedBox(
                width: screenWidth * 0.7,
                child: Text(
                  textAlign: TextAlign.center,
                  userAbout,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF757575),
                  ),
                ),
              ),

              SizedBox(height: 20),

              const Divider(
                color: Color(0xFF757575),
                thickness: 0.5,
                indent: 20,
                endIndent: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kitaplarım',
                    style: GoogleFonts.bebasNeue(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.5),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _fetchData('favorite_books');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(100, 43),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      'Önerilerim',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _fetchData('books');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(100, 43),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      'Paylaştıklarım',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(
                color: Color(0xFF757575),
                thickness: 0.5,
                indent: 20,
                endIndent: 20,
              ),

              //Kullanıcı eleştirileri
              UserReviewService(
                userNameSurname: '$userName $userSurname',
                userNickname: userNickname,
                userProfileImagePath: userProfileImagePath,
                comingUserID: widget.comingUserID,
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(),
      );
    } else {
      return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.generalBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            '$userNickname Profili',
            style: TextStyle(
                color: AppColors.white,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 23,
                letterSpacing: 1),
          ),
          elevation: 20,
          backgroundColor: AppColors.imagePickerUsageAppBarColor,
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
        ),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.38,
                width: screenWidth,
                //PROFİL FOTO
                child: GetPhotosService(
                  comingUserID: widget.comingUserID,
                ),
              ),

              //isim
              Text(
                ('$userName $userSurname'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1,
                ),
              ),

              //nickname
              Text(
                (userNickname),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF757575),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              //hakkında
              SizedBox(
                width: screenWidth * 0.7,
                child: Text(
                  textAlign: TextAlign.center,
                  userAbout,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF757575),
                  ),
                ),
              ),

              SizedBox(height: 20),

              const Divider(
                color: Color(0xFF757575),
                thickness: 0.5,
                indent: 20,
                endIndent: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kitaplarım',
                    style: GoogleFonts.bebasNeue(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.5),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _fetchData('favorite_books');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(100, 43),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      'Önerilerim',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _fetchData('books');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(100, 43),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      'Paylaştıklarım',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(
                color: Color(0xFF757575),
                thickness: 0.5,
                indent: 20,
                endIndent: 20,
              ),

              //Kullanıcı eleştirileri
              UserReviewService(
                userNameSurname: '$userName $userSurname',
                userNickname: userNickname,
                userProfileImagePath: userProfileImagePath,
                comingUserID: widget.comingUserID,
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(),
      );
    }
  }
}
