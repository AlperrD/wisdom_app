// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pau_ybs_kitap_paylasim_tez/services/photo_provider.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/home_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/profile_pages/profile_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/register_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/profile_photos/add_profile_photos.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../widgets/textfield.dart';

class CreateProfile extends StatefulWidget {
  final String? comingCurrentUserID;
  final String? currentUserName;
  final String? currentUserSurname;
  final String? currentUserNickName;
  final String? currentUserAbout;
  final String? currentUserProfileImage;
  final String? currentUserCoverImage;
  final String? createProfileEmail;
  final String? createProfilePassword;

  const CreateProfile({
    super.key,
    this.comingCurrentUserID,
    this.currentUserProfileImage,
    this.currentUserCoverImage,
    this.currentUserName,
    this.currentUserSurname,
    this.currentUserNickName,
    this.currentUserAbout,
    this.createProfileEmail,
    this.createProfilePassword,
  });

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile>
    with TickerProviderStateMixin {
  TextEditingController _userName = TextEditingController();
  TextEditingController _userSurname = TextEditingController();
  TextEditingController _userNickname = TextEditingController();
  TextEditingController _userAbout = TextEditingController();
  late final AnimationController _succesController;
  late final AnimationController _failController;
  late final AnimationController _loadingController;
  late MyData myData;
  String? createProfileEmail;
  String? createProfilePassword;
  XFile? selectedImageProfile;
  XFile? selectedImageCover;

  @override
  void initState() {
    super.initState();

    if (widget.comingCurrentUserID != null) {
      _userName = TextEditingController(text: widget.currentUserName);
      _userSurname = TextEditingController(text: widget.currentUserSurname);
      _userNickname =
          TextEditingController(text: widget.currentUserNickName!.substring(1));
      _userAbout = TextEditingController(text: widget.currentUserAbout);
    }
    _succesController = AnimationController(
      vsync: this,
    );
    _failController = AnimationController(
      vsync: this,
    );
    _loadingController = AnimationController(
      vsync: this,
    );
    _failController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _failController.reset();
      }
    });
  }

  @override
  void dispose() {
    _userName.dispose();
    _userSurname.dispose();
    _userNickname.dispose();
    _userAbout.dispose();
    _succesController.dispose();
    _failController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  //Asset yolunu file yolu olarak vermemizi sağlayan fonksiyon
  //https://stackoverflow.com/questions/55295593/how-to-convert-asset-image-to-file
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  //Profil bilgilerini databese tarafına yollama(Ayrı dosyaya alınacak, customelevatedbuttona parametre olarak yollamanın yolunu bul).
  Future createOrUpdateProfileInfos() async {
    //Kullanıcı profil bilgileri
    if (_userName.text.isNotEmpty &&
        _userSurname.text.isNotEmpty &&
        _userNickname.text.isNotEmpty &&
        _userAbout.text.isNotEmpty) {
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
      //Sıfırdan profil oluşturma sayfasında çalışan kod
      if (widget.comingCurrentUserID == null) {
        myData = Provider.of<DataProvider>(context, listen: false).myData;

        if (myData.data1 == null && myData.data2 == null) {
          XFile? xFileSelectedImageProfile;
          XFile? xFileSelectedImageCover;

          late File backgroundImageFileVar;
          late File profilePictureFileVar;

          profilePictureFileVar =
              await getImageFileFromAssets('assets/images/profile_avatar.png');
          backgroundImageFileVar = await getImageFileFromAssets(
              'assets/images/profile_background.png');

          xFileSelectedImageProfile = XFile(profilePictureFileVar.path);
          xFileSelectedImageCover = XFile(backgroundImageFileVar.path);

          selectedImageProfile = xFileSelectedImageProfile;
          selectedImageCover = xFileSelectedImageCover;
          createProfileEmail = widget.createProfileEmail;
          createProfilePassword = widget.createProfilePassword;
        } else {
          createProfileEmail = myData.email!;
          createProfilePassword = myData.password!;
          selectedImageProfile = myData.data1!;
          selectedImageCover = myData.data2!;
        }
        //kullanıcı oluşturma
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: createProfileEmail!,
            password: createProfilePassword!,
          );
          await FirebaseFirestore.instance
              .collection('kullaniciBilgileri')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            'id': FirebaseFirestore.instance
                .collection('kullaniciBilgileri')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .id,
            'email': createProfileEmail,
            'user_name': _userName.text.trim(),
            'user_surname': _userSurname.text.trim(),
            'user_nickname': '@${_userNickname.text.trim()}',
            'user_about': _userAbout.text.trim(),
          });
          await _uploadPhotoData(FirebaseAuth.instance.currentUser!.uid);
          Navigator.pop(context);
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
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => HomePage(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        } on FirebaseAuthException catch (e) {
          Navigator.pop(context);
          await showDialog(
            context: context,
            builder: (context) {
              return Lottie.asset(
                'assets/animations/fail.json',
                controller: _failController,
                onLoaded: (composition) {
                  _failController
                    ..duration = composition.duration
                    ..forward().then((_) => Navigator.pop(context));
                },
              );
            },
          );
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Hata!"),
                content: Text('Hata : ${e.message}.'),
                actions: [
                  TextButton(
                      onPressed: (() {
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => RegisterPage(),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(-1.0,
                                      0.0), // Başlangıç pozisyonu (sola kaydır)
                                  end: Offset
                                      .zero, // Bitiş pozisyonu (hedef konum)
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves
                                      .decelerate, // Geçişi yavaşlatan eğri
                                )),
                                child: child,
                              );
                            },
                          ),
                        );
                      }),
                      child: const Text("Geri Dön"))
                ],
              );
            },
          );
        }
      }
      //Profil güncelleme sayfasında çalışan kod
      else {
        await FirebaseFirestore.instance
            .collection('kullaniciBilgileri')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'user_name': _userName.text.trim(),
          'user_surname': _userSurname.text.trim(),
          'user_nickname': '@${_userNickname.text.trim()}',
          'user_about': _userAbout.text.trim(),
        });

        await FirebaseFirestore.instance
            .collection('books')
            .where('Person Who Added',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({
              'UserNickname': '@${_userNickname.text.trim()}',
            });
          }
        });

        await FirebaseFirestore.instance
            .collection('contactLists')
            .where('reciverID',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({
              'reciverUserName': _userName.text.trim(),
              'reciverUserSurname': _userSurname.text.trim(),
              'reciverUserNickname': '@${_userNickname.text.trim()}',
            });
          }
        });

        await FirebaseFirestore.instance
            .collection('contactLists')
            .where('senderID',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({
              'senderUserName': _userName.text.trim(),
              'senderUserSurname': _userSurname.text.trim(),
              'senderUserNickname': '@${_userNickname.text.trim()}',
            });
          }
        });

        Navigator.pop(context);
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
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProfilePage(),
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
      await showDialog(
        context: context,
        builder: (context) {
          return Lottie.asset(
            'assets/animations/fail.json',
            controller: _failController,
            onLoaded: (composition) {
              _failController
                ..duration = composition.duration
                ..forward().then((_) => Navigator.pop(context));
            },
          );
        },
      );
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Hata!"),
            content: Text("Lütfen profil bilgilerinizi tam doldurunuz."),
            actions: [
              TextButton(
                  onPressed: (() => Navigator.pop(context)),
                  child: Text("Geri Dön"))
            ],
          );
        },
      );
    }
  }

  //-------------------------------------------------------------------------
  // Firebase'e profil fotoğraflarını ekleyen fonksiyon
  // Profil oluşturma fotoğraf fonksiyonu
  Future<void> _uploadPhotoData(String userId) async {
    // Firebase storage referansı
    final FirebaseStorage storage = FirebaseStorage.instance;

    // Firebase storage'de kullanıcı idsine göre bir klasör oluşturur
    final Reference profileImageRef = storage
        .ref()
        .child(userId)
        .child('Profil Fotograflari')
        .child('avatar.jpg');

    final Reference coverImageRef = storage
        .ref()
        .child(userId)
        .child('Profil Fotograflari')
        .child('kapakFotografi.jpg');

    // Fotoğrafı Firebase storage'a yükler
    final UploadTask uploadTaskProfile =
        profileImageRef.putFile(File(selectedImageProfile!.path));
    final UploadTask uploadTaskCover =
        coverImageRef.putFile(File(selectedImageCover!.path));

    // Fotoğrafın url'ini alır
    final String profileImageUrl =
        await (await uploadTaskProfile).ref.getDownloadURL();
    final String coverImageUrl =
        await (await uploadTaskCover).ref.getDownloadURL();

    // Firestore referansı oluşturur
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Firestore'a profil ve kapak fotoğrafı bilgilerini ekler
    await firestore.collection('kullaniciBilgileri').doc(userId).update({
      'profile_image': profileImageUrl,
      'cover_image': coverImageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    //PROFİL GÜNCELLEME
    if (widget.comingCurrentUserID != null) {
      return Scaffold(
        backgroundColor: AppColors.generalBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Profil Güncelleme',
            style: TextStyle(
                color: AppColors.white,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 23,
                letterSpacing: 1),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
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
          elevation: 20,
          backgroundColor: AppColors.imagePickerUsageAppBarColor,
        ),
        //resizeToAvoidBottomInset widgetların yukarı kaymasını engeller
        //resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(children: [
                SizedBox(
                  height: screenHeight * 0.38,
                  width: screenWidth,
                  child: AddProfilePhotos(
                    isComingFromUpdate: true,
                    updateCurrentUserProfileImage:
                        widget.currentUserProfileImage,
                    updateCurrentUserCoverImage: widget.currentUserCoverImage,
                  ),
                ),
              ]),
              //kullanıcı adı input alanı
              CustomTextfield(
                fieldController: _userName,
                labelTextValue: 'İsim',
                verticalValue: 3,
                horizontalValue: 23,
              ),
              //kullanıcı soyadı input alanı
              CustomTextfield(
                fieldController: _userSurname,
                labelTextValue: 'Soyisim',
                verticalValue: 5,
                horizontalValue: 23,
              ),
              //nickname
              CustomTextfield(
                fieldController: _userNickname,
                labelTextValue: 'Kullanıcı Adı',
                verticalValue: 5,
                horizontalValue: 23,
              ),
              //hakkında input alanı
              CustomTextfield(
                fieldController: _userAbout,
                labelTextValue: 'Hakkında',
                verticalValue: 5,
                horizontalValue: 23,
                containerHeight: 80,
                maxLines: 3,
                maxLength: 99,
              ),

              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await createOrUpdateProfileInfos();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(200, 43),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      'Güncelle',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
    //SIFIRDAN PROFİL OLUŞTURMA
    else {
      return Scaffold(
        backgroundColor: AppColors.generalBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          actions: null,
          toolbarHeight: 50,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          title: const Text(
            '  Profil Oluştur',
            style: TextStyle(
                color: AppColors.white,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 25,
                letterSpacing: 1),
          ),
          elevation: 20,
          backgroundColor: AppColors.imagePickerUsageAppBarColor,
        ),
        //resizeToAvoidBottomInset widgetların yukarı kaymasını engeller
        //resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.38,
                width: screenWidth,
                child: AddProfilePhotos(
                  isComingFromUpdate: false,
                  createProfileEmail: widget.createProfileEmail,
                  createProfilePassword: widget.createProfilePassword,
                ),
              ),
              //kullanıcı adı input alanı
              CustomTextfield(
                fieldController: _userName,
                labelTextValue: 'İsim',
                verticalValue: 3,
                horizontalValue: 23,
              ),
              //kullanıcı soyadı input alanı
              CustomTextfield(
                fieldController: _userSurname,
                labelTextValue: 'Soyisim',
                verticalValue: 5,
                horizontalValue: 23,
              ),
              //nickname
              CustomTextfield(
                fieldController: _userNickname,
                labelTextValue: 'Kullanıcı Adı',
                verticalValue: 5,
                horizontalValue: 23,
              ),
              //hakkında input alanı
              CustomTextfield(
                fieldController: _userAbout,
                labelTextValue: 'Hakkında',
                verticalValue: 5,
                horizontalValue: 23,
                containerHeight: 80,
                maxLines: 3,
                maxLength: 99,
              ),

              SizedBox(
                height: 15,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await createOrUpdateProfileInfos();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(200, 43),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      'Oluştur',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }
}
