// ignore_for_file: unused_field, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/empty_profile_books_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';
import '../../config/theme/app_colors.dart';
import '../../services/location_permisson_service.dart';
import 'profile_pages/profile_sharing_books_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/profile_pages/profile_favorite_books_page.dart';

class ImagePickerUsage extends StatefulWidget {
  const ImagePickerUsage({super.key});

  @override
  State<ImagePickerUsage> createState() => _imagePickerUsageState();
}

// ignore: camel_case_types
class _imagePickerUsageState extends State<ImagePickerUsage>
    with TickerProviderStateMixin {
  late final AnimationController _failController;
  late final AnimationController _loadingController;
  late final AnimationController _succesController;
  // Form Alanı kontrolleri için controllerler.
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _bookAuthorController = TextEditingController();
  final TextEditingController _yearOfPublicationController =
      TextEditingController();
  final TextEditingController _bookDescriptionController =
      TextEditingController();
  //final TextEditingController _bookLocationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _imagePath;
  // Seçilen fotoğrafı tutmak için tanımlanan değişken
  XFile? _selectedImage;
  String _bookYear = '';
  String _bookWriter = '';
  String _bookName = '';
  String _YearOfPublication = '';
  String _personWhoAdded = '';
  String _BookDescription = '';
  String seciliTur = 'Roman';
  var enlem; // y latitude
  var boylam; // x longitude 'Konum ise (boylam ; enlem)'

  int textControl = 0;
  final ImagePicker _picker = ImagePicker();
  int selectedOption =
      0; // 0: Favori kitaplarım, 1: Paylaşacağım kitpalarım (ADEM)
  String userNickname = '';
  // Galeriden fotoğraf seçmek için fonksiyon
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 25); //kaliteyi orjinalin yüzde 25 oranında düşür.
    // Fotoğraf seçildiyse tanımladığımız değişkene atama işlemi.
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  //kameradan resim çekme fonksiyonu
  Future<void> _pickImageCamera() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 25);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserNickname();
    _konumIzniVeKaydet();
    _failController = AnimationController(
      vsync: this,
    );

    _loadingController = AnimationController(
      vsync: this,
    );

    _succesController = AnimationController(
      vsync: this,
    );

    //Animasyonların aynı sayfada 2. kez oynatılmasını sağlayan kodlar
    _failController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _failController.reset();
      }
    });

    _loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _loadingController.reset();
      }
    });
  }

  // Firebase'e veri ekleme fonksiyonu.
  Future<void> _uploadData(int selectedOption) async {
    // Form alanlarının boş olmadığının kontrolü
    //_bookLocationController.text.isNotEmpty && //sonradan oluşturulacak(alper)
    if (_bookNameController.text.isNotEmpty &&
        _bookAuthorController.text.isNotEmpty &&
        _selectedImage != null) {
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

      // Firebase authentication idsini tutan değişken
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // Firebase storage'de kitap adına göre bir klasör.
      final Reference ref =
          storage.ref().child(userId).child('${_bookNameController.text}.jpg');

      // Fotoğrafı Firebase storage'a yükleme.
      final UploadTask uploadTask = ref.putFile(File(_selectedImage!.path));

      // Fotoğrafın url'sini alan değişken.
      final String imageUrl = await (await uploadTask).ref.getDownloadURL();
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      //Date.time değişkeni zamanı doğru almıyordu 103. satırdaki kod direkt server saatini alıyor
      //Bundan sonra tarihle işin olursa FieldValue.serverTimestamp() kullan
      // 0: Favori kitaplarım, 1: Paylaşacağım kitpalarım (ADEM)
      if (selectedOption == 0) {
        await firestore.collection('favorite_books').add({
          'Book Name': _bookNameController.text,
          'Author': _bookAuthorController.text,
          //'location': _bookLocationController.text, //sonradan gelecek.(alper)
          'Image': imageUrl,
          'Year Of Publication': _yearOfPublicationController.text,
          'Person Who Added': userId,
          'Upload Date': FieldValue.serverTimestamp(),
          'Description': _bookDescriptionController.text,
          'UserNickname': userNickname,
          'Kategori': seciliTur,
          'Enlem': enlem,
          'Boylam': boylam,
        });
      } else {
        //'books' kısmını olduğu gibi bırakıyorum başka yerde sorguların vardır diye
        //shared_books olarak değiştirirsin (ADEM)
        await firestore.collection('books').add({
          'Book Name': _bookNameController.text,
          'Author': _bookAuthorController.text,
          //'location': _bookLocationController.text, //sonradan gelecek (alper)
          'Image': imageUrl,
          'Year Of Publication': _yearOfPublicationController.text,
          'Person Who Added': userId,
          'Upload Date': FieldValue.serverTimestamp(),
          'Description': _bookDescriptionController.text,
          'UserNickname': userNickname,
          'Kategori': seciliTur,
          'Enlem': enlem,
          'Boylam': boylam,
        });
      }

      // Form alanlarını ve seçilen fotoğrafı temizleme işlemleri.
      _bookNameController.clear();
      _bookAuthorController.clear();
      _yearOfPublicationController.clear();
      _bookDescriptionController.clear();
      //_bookLocationController.clear();
      setState(() {
        _selectedImage = null;
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
            title: Text("Uyarı!"),
            content: Text("Kitap bilgilerinizi tam doldurunuz."),
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

  Future<void> _konumIzniVeKaydet() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    try {
      await LocationPermissionsHandler.checkAndNavigateToSettings(context);

      // Konum izinleri verildiyse konum verilerini al
      Position konum = await Geolocator.getCurrentPosition();

      //TEK TEK STRİNG YERİNE DİREK GEOPOİNT İLE ALMA
      //enlemBoylam = GeoPoint(konum.latitude, konum.longitude);
      if (mounted) {
        setState(() {
          enlem = konum.latitude;
          print(enlem);
          boylam = konum.longitude;
          print(boylam);
        });
      }
    } catch (e) {
      // Hata yönetimi
      // Kullanıcıya bir hata mesajı göster
      // Örneğin: showDialog ile kullanıcıya bilgi vermek
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // Dialog dışına tıklama kapalı
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hata'),
              content: textControl == 0
                  ? Text('Lütfen konum izinlerini aktif edin.')
                  : Text('Konum izni ver, veya izin verdiysen kontrol et.'),
              actions: <Widget>[
                // TextButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //     _konumIzniVeKaydet(); // Yeniden izinleri kontrol et
                //   },
                //   child: const Text('İzinleri kontrol et'),
                // ),
                TextButton(
                  onPressed: () {
                    if (!serviceEnabled ||
                        (permission == LocationPermission.denied ||
                            permission == LocationPermission.deniedForever)) {
                      Navigator.pop(context);
                      _konumIzniVeKaydet();
                      setState(() {
                        textControl = 1;
                      });
                    } else {
                      Navigator.pop(context);
                      LocationPermissionsHandler.checkAndNavigateToSettings(
                          context);
                    }
                  },
                  child: const Text('İzin ver & Kontrol et'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  //firebaseden kullanıcı adlarını kitap verisine eklemek için kullaniciBilgilerinden user_nickname çeken fonksiyon
  Future<void> fetchUserNickname() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Belirli bir kullanıcıya ait belgeyi getir
      DocumentSnapshot userDoc =
          await firestore.collection('kullaniciBilgileri').doc(userId).get();
      if (userDoc.exists) {
        // Eğer belge varsa, kullanıcı adını yazdır
        setState(() {
          userNickname = userDoc['user_nickname'];
        });
        print(userNickname);
      } else {
        // Eğer belge yoksa, bir hata mesajı yazdır
        print("Belirtilen kullanıcı için bir nickname bulunamadı.");
      }
    } catch (e) {
      // Hata durumunda bir hata mesajı yazdır
      print("Nickname çekerken bir hata oluştu: $e");
    }
  }

  // Firebase'den veri çekmek için tanımlanan fonksiyon.
  Future<void> _fetchData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final QuerySnapshot snapshot;

    // Firestore'dan kitap koleksiyonunu alın
    //https://www.youtube.com/watch?v=StL0_12nBkQ orderby sorunu bu şekilde halledildi silme not kalsın(ADEM)
    if (selectedOption == 0) {
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

    // Kitap verilerini liste olarak alan değişken
    final List<QueryDocumentSnapshot> books = snapshot.docs;

    // Kitap verilerini başka bir ekranda göstermek için navigator.push metodu.
    if (selectedOption == 0) {
      if (books.isNotEmpty) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FavoriteBookListPage(
              books: books,
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
            pageBuilder: (_, __, ___) => const emptyBookListPage(),
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
            pageBuilder: (_, __, ___) => const emptyBookListPage(),
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

  //BU FONKSİYON GALİBA KULLANILMIYOR GEREKSİZSE SİLERSİN (ADEM)
  void _handleSubmitted() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      // perform book upload logic here
    }
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _bookAuthorController.dispose();
    _bookDescriptionController.dispose();
    _yearOfPublicationController.dispose();
    _loadingController.dispose();
    _failController.dispose();
    _succesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double deviceWidth = mediaQueryData.size.width;
    final double deviceHeight = mediaQueryData.size.height;
    print(deviceWidth);

    final double heightInDesign = 304;
    final double widthInDesign = 344;
    final double padding = 16;
    final double spaceBetween = 24;

    final double responsiveWidth = widthInDesign / deviceWidth;

    final double responsiveHeight = heightInDesign / deviceHeight;

    return Scaffold(
      backgroundColor: AppColors.generalBackground,
      appBar: AppBar(
        toolbarHeight: 50,
        automaticallyImplyLeading: false,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: const Text(
          'Kitap Ekle',
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
          child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: deviceHeight * responsiveHeight,
                    width: deviceWidth * responsiveWidth,
                    decoration: BoxDecoration(
                      // Transparent arka plan
                      borderRadius:
                          BorderRadius.circular(20), // Köşeleri yuvarlat
                      color: Color.fromARGB(255, 217, 222, 238),
                      // border:
                      //     Border.all(color: Colors.black, width: 3), // Siyah çerçeve
                      //     boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.purple.withOpacity(0.09), // 3D gölge efekti
                      //     spreadRadius: 2,
                      //     blurRadius: 5,
                      //     offset: Offset(0, 3), // Gölgelendirme yönü
                      //   ),
                      // ],
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
                                        borderRadius: BorderRadius.circular(50),
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
                              // Transparent arka plan
                              borderRadius: BorderRadius.circular(
                                  30), // Köşeleri yuvarlat
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
                                    onPressed: () => _pickImageCamera(),
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
                                      color: Colors.black, fontSize: 14),
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
                                      color: Colors.black, fontSize: 14),
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
            const SizedBox(
              height: 10,
            ),

            //Kitap adı textfield
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _bookNameController,
                decoration: InputDecoration(
                  labelText: 'Kitap Adı',
                  hintText: 'Ör: Yüzüklerin Efendisi',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen bir kitap adı giriniz.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _bookName = value!;
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            //Yazar adı textfield
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _bookAuthorController,
                decoration: InputDecoration(
                  labelText: 'Yazar Adı',
                  hintText: 'Ör: J.R.R Tolkien',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen bir kitap adı giriniz.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _bookWriter = value!;
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            //Kitap adı textfield
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _yearOfPublicationController,
                decoration: InputDecoration(
                  labelText: 'Basım yılı',
                  hintText: 'Ör: 1954',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen bir kitap adı giriniz.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _YearOfPublication = value!;
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _bookDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Kitap Açıklaması',
                  hintText: 'Ör: Fantazi evreninin mihenk taşı!',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen bir kitap adı giriniz.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _BookDescription = value!;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    // Input dekorasyonu eklendi
                    labelText: 'Kategori Seçiniz', // Label metni eklendi
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12.0)), // Kenarlık stili
                  ),
                  value: seciliTur,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.black),
                  onChanged: (String? yeniTur) {
                    setState(() {
                      seciliTur = yeniTur!;
                    });
                  },
                  items: <String>[
                    'Roman',
                    'Bilim Kurgu',
                    'Polisiye',
                    'Tarih',
                    'Diğer'
                  ].map<DropdownMenuItem<String>>((String deger) {
                    return DropdownMenuItem<String>(
                      value: deger,
                      child: Text(deger,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight
                                  .bold)), // Ekran genişliğine göre boyut ayarlama
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                SizedBox(
                  width: deviceWidth * 0.5,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Row(
                      children: [
                        Text('Önerilerim'),
                      ],
                    ),
                    leading: Radio(
                      value: 0,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: deviceWidth * 0.5,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Row(
                      children: [
                        Text('Paylaştıklarım '),
                      ],
                    ),
                    leading: Radio(
                      value: 1,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                onPressed: () {
                  _uploadData(selectedOption);
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
                child: const Text(
                  'Kitap Ekle',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  _fetchData();
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
                child: const Text(
                  'Kitap Göster',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ]),
          ],
        ),
      )),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}

// class LocationPermissionsHandler {
//   static Future<void> checkAndNavigateToSettings(BuildContext context) async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openAppSettings();
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         await Geolocator.openAppSettings();
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return;
//     }
//   }
// }

// enum menus{
//   home,
//   chat,
//   profile,
//   addBooks,
//   search,
// }

// final pages=[
//   ImagePickerUsage(),//add Books kısmı.
//   ProfilePage(), //profil sayfası

// ];
