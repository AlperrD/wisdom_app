// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/profile_pages/profile_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/textfield.dart';
import '../../../config/theme/app_colors.dart';

class UserReview extends StatefulWidget {
  const UserReview({super.key});

  @override
  State<UserReview> createState() => _UserReviewState();
}

class _UserReviewState extends State<UserReview> with TickerProviderStateMixin {
  final TextEditingController _userReview = TextEditingController();
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  late final AnimationController _succesController;
  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _succesController = AnimationController(
      vsync: this,
    );
    _loadingController = AnimationController(
      vsync: this,
    );
    _loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _loadingController.reset();
      }
    });
  }

  @override
  void dispose() {
    _userReview.dispose();
    _succesController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future addUserReview(String userReview) async {
    if (_userReview.text.isNotEmpty && _selectedImage != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Lottie.asset(
            'assets/animations/loading.json',
            controller: _loadingController,
            onLoaded: (composition) {
              _loadingController
                ..duration = composition.duration
                ..repeat();
            },
          );
        },
      );
      String reviewId =
          FirebaseFirestore.instance.collection('userReviews').doc().id;
      // Firebase storage referansı
      final FirebaseStorage storage = FirebaseStorage.instance;

      // Firebase authentication id
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // Firebase storage'de kullanıcı idsine göre bir klasör oluşturur
      final Reference reviewImageRef = storage
          .ref()
          .child(userId)
          .child('Elestiri Fotograflari')
          .child('$reviewId.jpg');

      // Fotoğrafı Firebase storage'a yükler
      final UploadTask uploadTaskProfile =
          reviewImageRef.putFile(File(_selectedImage!.path));

      // Fotoğrafın url'ini alır
      final String reviewImageUrl =
          await (await uploadTaskProfile).ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('userReviews')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('reviews')
          .doc(reviewId)
          .set({
        'user_id': FirebaseFirestore.instance
            .collection('kullaniciBilgileri')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .id,
        'user_review': userReview,
        //Farklı bölgelerin saatleri farklı olabileceğinden dolayı server saati alındı.
        'timestamp': FieldValue.serverTimestamp(),
        'user_review_photo': reviewImageUrl,
      });
      setState(() {
        _selectedImage = null;
      });
      Navigator.pop(context);
      _userReview.clear();
      await showDialog(
        context: context,
        builder: (context) {
          return Lottie.asset(
            'assets/animations/succes.json',
            controller: _succesController,
            onLoaded: (composition) {
              _succesController
                ..duration = composition.duration
                ..forward().then((_) => Navigator.pop(context));
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen görsel ve metin alanlarını doldurunuz.'),
        ),
      );
    }
  }

  Future createUserReview() async {
    await addUserReview(_userReview.text.trim());
  }

  // Fotoğraf seçmek için fonksiyon tanımlayın
  Future<void> _pickImage() async {
    // Kamera veya galeriden fotoğraf seçin
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // Fotoğraf seçildiyse, durumu güncelleyin
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _selectImageCamera() async {
    // Kamera veya galeriden fotoğraf seçin
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    // Fotoğraf seçildiyse, durumu güncelleyin
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.generalBackground,
      appBar: AppBar(
        toolbarHeight: 50,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: const Text(
          'Kitap Eleştirisi',
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 304,
                      width: 344,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 217, 222, 238),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              height: 290,
                              width: 255,
                              decoration: BoxDecoration(
                                color: AppColors.generalBackground,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_selectedImage != null)
                                      Container(
                                        width: 250,
                                        height: 250,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: AppColors.generalBackground,
                                        ),
                                        child: Image.file(
                                          fit: BoxFit.cover,
                                          File(_selectedImage!.path),
                                          height: 260,
                                          width: 240,
                                        ),
                                      )
                                    else
                                      Image.asset(
                                        'assets/images/empty-folder.png',
                                        height: 290,
                                        width: 255,
                                      )
                                  ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              height: 290,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.black,
                                    width: 2), // Siyah çerçeve
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 50.0),
                                    child: IconButton(
                                      padding: EdgeInsets.only(right: 5),
                                      onPressed: () => _selectImageCamera(),
                                      icon: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.black,
                                        size: 50,
                                      ),
                                      tooltip: 'Kamera',
                                    ),
                                  ),
                                  const Text(
                                    'Kamera',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.only(right: 5),
                                    onPressed: () => _pickImage(),
                                    icon: const Icon(
                                      Icons.photo_camera_back_outlined,
                                      size: 50,
                                      color: Colors.black,
                                    ),
                                    tooltip: 'Galeri',
                                  ),
                                  const Text(
                                    'Galeri',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              CustomTextfield(
                fieldController: _userReview,
                labelTextValue: 'Eleştiriniz',
                containerHeight: 130,
                horizontalValue: 10,
                maxLines: 11,
                maxLength: 500,
                color: Color.fromARGB(255, 217, 222, 238),
              ),
              ElevatedButton(
                onPressed: () async {
                  await createUserReview();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(260, 43),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                child: const Text(
                  'Paylaş',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}
