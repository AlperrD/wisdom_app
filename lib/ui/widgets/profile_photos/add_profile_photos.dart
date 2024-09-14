// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, no_logic_in_create_state

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../services/photo_provider.dart';

class AddProfilePhotos extends StatefulWidget {
  final bool? isComingFromUpdate;
  final String? updateCurrentUserProfileImage;
  final String? updateCurrentUserCoverImage;
  final String? createProfileEmail;
  final String? createProfilePassword;
  const AddProfilePhotos({
    super.key,
    required this.isComingFromUpdate,
    this.updateCurrentUserProfileImage,
    this.updateCurrentUserCoverImage,
    this.createProfileEmail,
    this.createProfilePassword,
  });

  @override
  State<AddProfilePhotos> createState() => _AddProfilePhotosState();
}

class _AddProfilePhotosState extends State<AddProfilePhotos>
    with TickerProviderStateMixin {
  late final AnimationController _loadingController;
  @override
  void initState() {
    // TODO: implement initState
    _loadingController = AnimationController(
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _loadingController.dispose();
    super.dispose();
  }

  //Profil fotoğrafı değişkenleri
  File? _profileImageFile;
  Image _profileImage = Image.asset('assets/images/profile_avatar.png');

  //Kapak fotoğrafı değişkenleri
  File? _coverImageFile;
  Image _coverImage = Image.asset('assets/images/profile_background.png');

  //Fotoğraf ekleme değişkenleri
  XFile? _selectedImageProfile;
  bool _selectedProfileImageBool = false;
  XFile? _selectedImageCover;
  bool _selectedCoverImageBool = false;
  final ImagePicker _picker = ImagePicker();

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

  //Profil fotoğrafı için galeriden fotoğraf seçme fonksiyonu
  Future<void> _pickProfileImageGallery() async {
    //Galeriden fotoğraf seçme
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    //Fotoğraf seçildiyse durumu güncelle
    if (image != null) {
      setState(() {
        _selectedImageProfile = image;
        _profileImageFile = File(_selectedImageProfile!.path);
        _profileImage = Image.file(_profileImageFile!);
        _selectedProfileImageBool = true;
      });
    }
  }

  //Profil fotoğrafı için kamerayla fotoğraf ekleme fonksiyonu
  Future<void> _selectProfileImageCamera() async {
    //Kamerayla fotoğraf çekme
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    //Fotoğraf seçildiyse durumu güncelle
    if (image != null) {
      setState(() {
        _selectedImageProfile = image;
        _profileImageFile = File(_selectedImageProfile!.path);
        _profileImage = Image.file(_profileImageFile!);
        _selectedProfileImageBool = true;
      });
    }
  }

  //Kapak fotoğrafı için kamerayla fotoğraf ekleme fonksiyonu
  Future<void> _selectCoverImageCamera() async {
    //Kamerayla fotoğraf çekme
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    //Fotoğraf seçildiyse durumu güncelle
    if (image != null) {
      setState(() {
        _selectedImageCover = image;
        _coverImageFile = File(_selectedImageCover!.path);
        _coverImage = Image.file(_coverImageFile!);
        _selectedCoverImageBool = true;
      });
    }
  }

  //Kapak fotoğrafı için galeriden fotoğraf seçme fonksiyonu
  Future<void> _pickCoverImageGallery() async {
    //Galeriden fotoğraf seçme
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    //Fotoğraf seçildiyse durumu güncelle
    if (image != null) {
      setState(() {
        _selectedImageCover = image;
        _coverImageFile = File(_selectedImageCover!.path);
        _coverImage = Image.file(_coverImageFile!);
        _selectedCoverImageBool = true;
      });
    }
  }

  //Fotoğraf yüklenmemesi durumunda default assetleri ilgili değişkenlere atayan fonksiyon
  Future<void> _setDefaultPaths() async {
    late File backgroundImageFileVar;
    late File profilePictureFileVar;

    if (_selectedImageCover == null || _selectedImageProfile == null) {
      if (_selectedImageCover == null && _selectedImageProfile != null) {
        backgroundImageFileVar = await getImageFileFromAssets(
            'assets/images/profile_background.png');
      } else if (_selectedImageProfile == null && _selectedImageCover != null) {
        profilePictureFileVar =
            await getImageFileFromAssets('assets/images/profile_avatar.png');
      } else {
        backgroundImageFileVar = await getImageFileFromAssets(
            'assets/images/profile_background.png');
        profilePictureFileVar =
            await getImageFileFromAssets('assets/images/profile_avatar.png');
      }

      setState(() {
        if (_selectedImageProfile == null) {
          _selectedImageProfile = XFile(profilePictureFileVar.path);
          _profileImageFile = File(_selectedImageProfile!.path);
          _profileImage = Image.file(_profileImageFile!);
        }
        if (_selectedImageCover == null) {
          _selectedImageCover = XFile(backgroundImageFileVar.path);
          _coverImageFile = File(_selectedImageCover!.path);
          _coverImage = Image.file(_coverImageFile!);
        }
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lütfen onay butonuna basınız.'),
      ),
    );
  }

  //Profil güncelleme fotoğraf fonksiyonu
  Future<void> _uploadData2() async {
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
    // Firebase storage referansı
    final FirebaseStorage storage = FirebaseStorage.instance;

    // Firebase authentication id
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    // Firestore referansı oluşturur
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (_selectedImageProfile != null || _selectedImageCover != null) {
      if (_selectedImageProfile != null && _selectedImageCover != null) {
        // Her ikisi de doluysa her ikisini de yükle
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

        final UploadTask uploadTaskProfile =
            profileImageRef.putFile(File(_selectedImageProfile!.path));
        final UploadTask uploadTaskCover =
            coverImageRef.putFile(File(_selectedImageCover!.path));

        final String profileImageUrl =
            await (await uploadTaskProfile).ref.getDownloadURL();
        final String coverImageUrl =
            await (await uploadTaskCover).ref.getDownloadURL();

        await firestore.collection('kullaniciBilgileri').doc(userId).update({
          'profile_image': profileImageUrl,
          'cover_image': coverImageUrl,
        });

        await firestore
            .collection('contactLists')
            .where('reciverID',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({
              'reciverProfilePhoto': profileImageUrl,
            });
          }
        });

        await firestore
            .collection('contactLists')
            .where('senderID',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({
              'senderProfilePhoto': profileImageUrl,
            });
          }
        });
      } else if (_selectedImageProfile != null && _selectedImageCover == null) {
        // Sadece profil fotoğrafı doluysa yükle
        final Reference profileImageRef = storage
            .ref()
            .child(userId)
            .child('Profil Fotograflari')
            .child('avatar.jpg');

        final UploadTask uploadTaskProfile =
            profileImageRef.putFile(File(_selectedImageProfile!.path));

        final String profileImageUrl =
            await (await uploadTaskProfile).ref.getDownloadURL();

        await firestore.collection('kullaniciBilgileri').doc(userId).update({
          'profile_image': profileImageUrl,
        });

        await firestore
            .collection('contactLists')
            .where('reciverID',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({
              'reciverProfilePhoto': profileImageUrl,
            });
          }
        });

        await firestore
            .collection('contactLists')
            .where('senderID',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({
              'senderProfilePhoto': profileImageUrl,
            });
          }
        });
      } else if (_selectedImageCover != null && _selectedImageProfile == null) {
        // Sadece kapak fotoğrafı doluysa yükle
        final Reference coverImageRef = storage
            .ref()
            .child(userId)
            .child('Profil Fotograflari')
            .child('kapakFotografi.jpg');

        final UploadTask uploadTaskCover =
            coverImageRef.putFile(File(_selectedImageCover!.path));

        final String coverImageUrl =
            await (await uploadTaskCover).ref.getDownloadURL();

        await firestore.collection('kullaniciBilgileri').doc(userId).update({
          'cover_image': coverImageUrl,
        });
      }
    } else {
      // Her ikisi de boşsa işlemi pas geç
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Herhangi bir fotoğraf güncellenmedi.'),
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    if (widget.isComingFromUpdate == true) {
      return Scaffold(
        backgroundColor: AppColors.generalBackground,
        //resizeToAvoidBottomInset widgetların yukarı kaymasını engeller
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            InkWell(
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return PopScope(
                      canPop: false,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: AlertDialog(
                          title: Text('Ekle', style: TextStyle(fontSize: 40)),
                          content:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Row(
                              children: [
                                Text(
                                  'Profil  Fotografı',
                                  style: TextStyle(fontSize: 25),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectProfileImageCamera();
                                    });
                                  },
                                  child: Icon(
                                    Icons.camera,
                                    size: 27,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _pickProfileImageGallery();
                                    });
                                  },
                                  child: Icon(
                                    Icons.filter,
                                    size: 27,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Kapak Fotografı',
                                  style: TextStyle(fontSize: 25),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectCoverImageCamera();
                                    });
                                  },
                                  child: Icon(
                                    Icons.camera,
                                    size: 27,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _pickCoverImageGallery();
                                    });
                                  },
                                  child: Icon(
                                    Icons.filter,
                                    size: 27,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                          actions: [
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _uploadData2();
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  minimumSize: Size(180, 40),
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Onayla',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Stack(
                children: [
                  //Kapak Fotoğrafı Alanı
                  Container(
                    //top:48
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    height: screenHeight * 0.28,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.generalBackground, width: 0.8),
                      image: DecorationImage(
                        alignment: Alignment(-2, -0.55),
                        image: _selectedCoverImageBool
                            ? _coverImage.image
                            : NetworkImage(widget.updateCurrentUserCoverImage!),
                        fit: BoxFit.cover,
                      ),
                      color: AppColors.generalBackground,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                    ),
                  ),
                  //Profil fotoğrafı
                  Padding(
                    //top:175
                    padding: EdgeInsets.only(top: 140),
                    child: Center(
                      child: CircleAvatar(
                        radius: 61,
                        backgroundColor: AppColors.generalBackground,
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: AppColors.generalBackground,
                          backgroundImage: _selectedProfileImageBool
                              ? _profileImage.image
                              : NetworkImage(
                                  widget.updateCurrentUserProfileImage!),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 60, top: 70),
                            child: Icon(
                              Icons.add_rounded,
                              size: 60,
                              color: Color.fromARGB(255, 255, 0, 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.generalBackground,
        //resizeToAvoidBottomInset widgetların yukarı kaymasını engeller
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            InkWell(
              onTap: () {
                _setDefaultPaths();
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return PopScope(
                      canPop: false,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: AlertDialog(
                          title: Text(
                            'Ekle',
                            style: TextStyle(fontSize: 40),
                          ),
                          content:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Row(
                              children: [
                                Text(
                                  'Profil  Fotografı',
                                  style: TextStyle(fontSize: 25),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectProfileImageCamera();
                                    });
                                  },
                                  child: Icon(
                                    Icons.camera,
                                    size: 27,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _pickProfileImageGallery();
                                    });
                                  },
                                  child: Icon(
                                    Icons.filter,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Kapak Fotografı',
                                  style: TextStyle(fontSize: 25),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectCoverImageCamera();
                                    });
                                  },
                                  child: Icon(
                                    Icons.camera,
                                    size: 27,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _pickCoverImageGallery();
                                    });
                                  },
                                  child: Icon(
                                    Icons.filter,
                                    size: 27,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                          actions: [
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Provider.of<DataProvider>(context,
                                          listen: false)
                                      .updateData(
                                          _selectedImageProfile,
                                          _selectedImageCover,
                                          widget.createProfileEmail!,
                                          widget.createProfilePassword!);
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  minimumSize: Size(180, 40),
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Onayla',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Stack(
                children: [
                  //Kapak Fotoğrafı Alanı
                  Container(
                    //top:48
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    height: screenHeight * 0.28,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.generalBackground, width: 0.8),
                      image: DecorationImage(
                        alignment: Alignment(-2, -0.55),
                        image: _coverImage.image,
                        fit: BoxFit.cover,
                      ),
                      color: AppColors.generalBackground,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                    ),
                  ),
                  //Profil fotoğrafı
                  Padding(
                    //top:175
                    padding: EdgeInsets.only(top: 140),
                    child: Center(
                      child: CircleAvatar(
                        radius: 61,
                        backgroundColor: AppColors.generalBackground,
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: AppColors.generalBackground,
                          backgroundImage: _profileImage.image,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 60, top: 70),
                            child: Icon(
                              Icons.add_rounded,
                              size: 60,
                              color: Color.fromARGB(255, 255, 0, 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
