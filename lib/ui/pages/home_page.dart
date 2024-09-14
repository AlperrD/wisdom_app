import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pau_ybs_kitap_paylasim_tez/config/theme/app_colors.dart';
import 'package:pau_ybs_kitap_paylasim_tez/services/login_auth_controller_service.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/home_page_search_books.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/login_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/books/home_page_show_books.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';
import 'dart:math' as Math;

import '../../services/location_permisson_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final user = FirebaseAuth.instance.currentUser;
  String userName = '';
  String _seciliKategori = 'tümü';
  List<DocumentSnapshot> _kitaplar = [];
  bool _yukleniyor = true;
  var colorContainer = AppColors.fosucIconColor;

  //late final List<QueryDocumentSnapshot> homePageBooks;
  final ScrollController _scrollController = ScrollController();
  TextEditingController _mesafeController = TextEditingController();

  Map<String, Color> Renkler = {
    "White": AppColors.white,
    'Purple': AppColors.fosucIconColor,
    'Grey': AppColors.grey
  };

  Map<String, String> quotes = {
    // Örnek özlü sözler ve yazarları
    "İnsan ne kadar isterse istesin, unutması olanaksızdır. Her şeyin, geçilmesi tehlikeli olan bir sınırı vardır. Bu sınır bir aşıldı mı artık geriye dönüş yoktur.":
        "Dostoyevski - Suç ve Ceza",
    "Zamanı saatlerle, dakikalarla değil, güneşin doğup batmasıyla değil, onunla ölçüyordum; onu gördüm görmedim, göreceğim görmeyeceğim, gelecek gelmeyecek.":
        "Aleksandroviç Gonçarov - Oblomov",
    "Zaman bazen kuş gibi uçar bazen de solucan gibi sürünerek geçer; ama insan en çok zamanın ağır mı yoksa çabuk mu geçtiğini fark etmediği vakit kendini iyi hisseder.":
        "Turgenyev - Babalar ve Oğullar",
    "Başka insanların yüzüne bakabilmek için ilk önce kendi yüzüme bakabilmeliyim. Çoğunluğa bağlı olmayan tek şey insanın vicdanıdır":
        "Harper Lee - Bülbülü Öldürmek",
    "Hürriyet olmayan bir memlekette ölüm ve çöküş vardır. Her ilerleyişin ve kurtuluşun anası hürriyettir.":
        "Mustafa Kemal Atatürk",
    "Bütün hayvanlar eşittir ama bazı hayvanlar daha eşittir.":
        "George Orwell - Hayvan Çiftliği",
    "Önce biraz ağladılar, ama alıştılar şimdi. Aşağılık insanoğlu her şeye alışır!":
        "Dostoyevski - Suç ve Ceza",
    "Sonra herkesin akıllı olmasını beklemenin çok uzun süreceğini anladım. Bir de bunun hiç bir zaman gerçekleşmeyeceğini, insanların değişmeyeceğini, onları değiştirecek kimsenin bulunmadığını ve bunun için çaba göstermeye değmeyeceğini.":
        "Dostoyevski - Suç ve Ceza",
    " Ne zaman bir yılgınlık, bir umutsuzluk çökse karıncaların üstüne, hemen ona karşı bir umut sözü bir ışık gibi yayılıyordu karınca ülkelerine... Ekmeksiz, susuz, havasız yaşayabilirlerdi de karıncalar, umutsuz yaşayamazlardı.":
        "Yaşar Kemal - Filler Sultanı ile Kırmızı Sakallı Topal Karınca",
    "Ve artık bilmesinin zamanı geldi! Gözlerini açmalı. Nefsine sahip çıkmasının zamanı geldi. Hayat, reddedemeyeceği kadar güzel ve gerçek. Bu hayatta umut, sevgi, dostluk, insanlık var! Ölümse boş bir kâğıt! Kayra, yolculuğunun parçaladığı hayatını toplayıp geri dönmelisin. Çünkü burada her şey var! Her şey var.":
        "Hakan Günday - Kinyas ve Kayra",
    "\'Daha çok anlat\' dedim. \n\'Hoşuna gidiyor mu?\'\n\'Çok. Elimden gelse seninle sekiz yüz elli iki bin kilometre hiç durmadan konuşurdum.\'\n\'Bu kadar yola nasıl benzin yetiştiririz?\'\n\'Gider gibi yaparız.\'":
        'Jose Mauro de Vasconcelos - Şeker Portakalı',
    "Konuşmam yetmiyormuş gibi düşünmeye de başladım. En kötüsü buydu. Çoğu insanlar gibi düşünmeden konuşsaydım kimse bir şey demeyecekti ama ben düşündüğümü söylemeye kalktım.":
        "Yusuf Atılgan - Aylak Adam",

    // Daha fazla özlü söz ekleyebilirsiniz.
  };
  String currentQuote = "";
  String currentAuthor = "";
  Timer? timer;
  var enlem; // y latitude
  var boylam; // x longitude 'Konum ise (boylam ; enlem)'
  List<DocumentSnapshot> filtrelenmisKitapListesi = [];
  String konumaGoreKategori = 'tümü';
  int textControl = 0;

  @override
  void initState() {
    super.initState();
    _konumIzniVeKaydet();
    Timer.periodic(Duration(seconds: 15), (Timer t) => _changeQuote());
    _changeQuote();
    currentQuote = quotes.keys.first;
    currentAuthor = quotes[currentQuote]!;
    //özlü söz güncelleme.
    //Timer.periodic(Duration(minutes: 1), (Timer t) => _changeQuote());
    getUserAbout(); // kullanıcı adının alınması
    _kitaplariGetir();

    //fetchUserNickname();
    //_fetchBookDataForHomePage();
  }

  // Future<void> _fetchBookDataForHomePage () async {
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   final QuerySnapshot snapshot;
  //   snapshot = await firestore.collection('books').orderBy('Upload Date',descending: true).get();
  //   final List<QueryDocumentSnapshot> books = snapshot.docs;

  //   setState(() {
  //     homePageBooks = books;
  //   });
  // }

  // Kullanıcı adını future kullanmadan alan fonksiyon.
  getUserAbout() {
    FirebaseFirestore.instance
        .collection('kullaniciBilgileri')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((gelenveri) {
      setState(() {
        userName = gelenveri.data()!['user_name'];
      });
    });
  }

  //firebaseden yeni verileri çeken kod !!!

  void _kitaplariGetir() async {
    setState(() {
      _yukleniyor = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('books')
          .orderBy('Upload Date', descending: true)
          .get();
      setState(() {
        _kitaplar = querySnapshot.docs;
        filtrelenmisKitapListesi = _kitaplar;
        _yukleniyor = false;
      });
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi vermek için bir yöntem ekleyin
      print('Kitaplar yüklenirken bir hata oluştu: $e');
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

  double deg2rad(double deg) {
    return deg * (pi / 180);
  }

  double uzaklikHesapla(double kitapEnlem, double kitapBoylam,
      double kullaniciEnlem, double kullaniciBoylam) {
    var R = 6371 * 1000; // Dünya'nın yarıçapı (metre cinsinden)
    var dEnlem = deg2rad(kullaniciEnlem - kitapEnlem);
    var dBoylam = deg2rad(kullaniciBoylam - kitapBoylam);

    var a = sin(dEnlem / 2) * sin(dEnlem / 2) +
        cos(deg2rad(kitapEnlem)) *
            cos(deg2rad(kullaniciEnlem)) *
            sin(dBoylam / 2) *
            sin(dBoylam / 2);

    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Uzaklık metre cinsinden

    return d;
  }

  void _showDialog(BuildContext context) {
    String? yeniKategori;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mesafe Girin'),
          content: TextField(
            onChanged: (value) {
              if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                // Sadece rakam girişini kabul et
                yeniKategori = value;
              }
            },
            keyboardType: TextInputType.number, // Klavye türünü sayısal yap
            decoration: InputDecoration(hintText: 'Mesafeyi girin'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Diyalog penceresini kapat
                if (yeniKategori != null) {
                  // Kategori değeri girildiyse işlem yap
                  _konumaGorekategoriSec(yeniKategori!);
                  filtreleVeYenile(double.parse(yeniKategori!));
                }
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void _kategoriSec(String kategori) {
    setState(() {
      if (_seciliKategori == kategori) {
        // Eğer aynı kategoriye tekrar tıklandıysa, filtreyi kaldır
        _seciliKategori = 'tümü'; // veya null, tercihinize bağlı
      } else {
        // Farklı bir kategori seçildiyse, filtreyi uygula
        _seciliKategori = kategori;
        konumaGoreKategori = 'tümü';
      }
    });
  }

  void _konumaGorekategoriSec(String kategori) {
    setState(() {
      if (konumaGoreKategori == kategori) {
        // Eğer aynı kategoriye tekrar tıklandıysa, filtreyi kaldır
        konumaGoreKategori = 'tümü'; // veya null, tercihinize bağlı
      } else {
        // Farklı bir kategori seçildiyse, filtreyi uygula
        konumaGoreKategori = kategori;
        _seciliKategori = 'tümü';
      }
    });
  }

  void filtreleVeYenile(double maksimumUzaklik) {
    setState(() {
      filtrelenmisKitapListesi = _kitaplar == null
          ? []
          : konumaGoreKategori == 'tümü'
              ? _kitaplar
              : _kitaplar.where((kitap) {
                  double uzaklik = uzaklikHesapla(
                      kitap['Enlem'], kitap['Boylam'], enlem!, boylam);
                  return uzaklik <= maksimumUzaklik;
                }).toList();
    });
    setState(() {});
  }

  void kategoriFiltrele() {
    filtrelenmisKitapListesi = _kitaplar == null
        ? []
        : _seciliKategori == 'tümü'
            ? _kitaplar
            : _kitaplar
                .where((kitap) => kitap['Kategori'] == _seciliKategori)
                .toList();
  }

//bu kısıma özlü söz güncelleme eklenecek.
  void _changeQuote() {
    if (!mounted) return; // Eğer widget ağaçta değilse, işlem yapma

    final randomIndex = Random().nextInt(quotes.length);
    final quoteEntry = quotes.entries.elementAt(randomIndex);

    final randomRenk = Random().nextInt(Renkler.length);
    final randomColor = Renkler.entries.elementAt(randomRenk);

    setState(() {
      currentQuote = quoteEntry.key;
      currentAuthor = quoteEntry.value;
      colorContainer = randomColor.value;
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Zamanlayıcıyı iptal edin
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//  filtrelenmisKitapListesi = _kitaplar == null
//         ? []
//         : _seciliKategori == 'tümü'
//             ? _kitaplar
//             : _kitaplar
//                 .where((kitap) => kitap['Kategori'] == _seciliKategori)
//                 .toList();

    return Scaffold(
        bottomNavigationBar: const CustomNavigationBar(),
        extendBody: false,
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          centerTitle: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          title: Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.height * 0.129,
            ),
            child: Text(
              'Ana Sayfa',
              style: TextStyle(
                  color: AppColors.white,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                  letterSpacing: 1),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                tooltip: 'Kitap Ara', // Arama iconu kullan
                onPressed: () {
                  // Arama butonuna tıklandığında yapılacak işlemleri buraya yazabilirsin
                  // Örneğin, arama sayfasını açabilirsin
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const SearchBooksPage(),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
          elevation: 20,
          backgroundColor: AppColors.imagePickerUsageAppBarColor,
        ),
        body: RawScrollbar(
          thumbColor: AppColors.imagePickerUsageAppBarColor,
          interactive: true,
          thickness: 5,
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.height * 0.02,
                    vertical: MediaQuery.of(context).size.width * 0.015),
                child: Text(
                  'Hoşgeldin, $userName 👋',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorContainer, // Transparent arka plan
                    borderRadius:
                        BorderRadius.circular(15), // Köşeleri yuvarlat
                    border: Border.all(
                        color: Colors.black, width: 2), // Siyah çerçeve
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // 3D gölge efekti
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // Gölgelendirme yönü
                      ),
                    ],
                  ),

                  // Özlü sözlerin gösterildiği container
                  child: InkWell(
                    onTap: () {
                      _changeQuote();
                    },
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 15, bottom: 20),
                          child: Text(
                            currentQuote,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, right: 20, bottom: 20),
                              child: Text(
                                currentAuthor,
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        )
                        // Diğer widget'lar...
                      ],
                    ),
                  ),
                ),
              ),

              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      'Filtreler',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color:
                            Colors.black, // You can choose any color you like
                        letterSpacing:
                            0, // Add spacing between letters for a stylish look
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 640,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromARGB(255, 206, 206, 243),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 3),
                            Text(
                              'kategori',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            _kategoriButonu('Bilim Kurgu'),
                            const SizedBox(width: 3),
                            _kategoriButonu('Polisiye'),
                            const SizedBox(width: 3),
                            _kategoriButonu('Roman'),
                            const SizedBox(
                              width: 3,
                            ),
                            _kategoriButonu('Fantastik'),
                            const SizedBox(
                              width: 3,
                            ),
                            _kategoriButonu('Korku'),
                            const SizedBox(
                              width: 3,
                            ),
                            _kategoriButonu('Tarih'),
                            const SizedBox(
                              width: 3,
                            ),
                            _kategoriButonu('Diğer'),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromARGB(255, 206, 206, 243),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              'Uzaklık',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            _kategoriButonu2(1000, '1000m'),
                            const SizedBox(
                              width: 3,
                            ),
                            _kategoriButonu2(2000, '2000m'),
                            const SizedBox(
                              width: 3,
                            ),
                            _kategoriButonu2(3000, '3000m'),
                            const SizedBox(
                              width: 10,
                            ),
                            _kategoriButonu3(4000, 'Manuel'),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Paylaşılan Kitaplar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black, // You can choose any color you like
                      letterSpacing:
                          2, // Add spacing between letters for a stylish look
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: ListView.builder(
                  itemCount: filtrelenmisKitapListesi.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot? kitap = filtrelenmisKitapListesi[index];
                    double uzaklik = 0; // Default value
                    if (enlem != null) {
                      uzaklik = uzaklikHesapla(
                          kitap['Enlem'], kitap['Boylam'], enlem!, boylam);
                    }

                    return ShowBooksHomePage(
                      imageUrl: kitap['Image'],
                      bookName: kitap['Book Name'],
                      bookAuthor: kitap['Author'],
                      userNickName: kitap['UserNickname'],
                      kategori: kitap['Kategori'],
                      uzaklik: uzaklik,
                      latitude: kitap['Enlem'],
                      longitude: kitap['Boylam'],
                      description: kitap['Description'],
                      date: kitap['Upload Date'],
                      addedPersonID: kitap['Person Who Added'],
                    );
                  },
                ),
              ),

              // Kategori butonları
              // title: Text(kitap?['Book Name'] ?? 'Kitap Adı Yok'),
              //               subtitle: Text(kitap?['Author'] ?? 'Yazar Bilinmiyor'),
            ],
          ),
        ));
  }

  Widget _kategoriButonu2(double mesafe, String Kategori) {
    return ElevatedButton(
      onPressed: () {
        _konumaGorekategoriSec(Kategori);
        filtreleVeYenile(mesafe);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: konumaGoreKategori == Kategori
            ? AppColors.fosucIconColor
            : AppColors.imagePickerUsageBottomAppBarColor,
        minimumSize: const Size(0, 35),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
      child: Text(
        Kategori,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: konumaGoreKategori == Kategori
              ? AppColors.black
              : AppColors.white,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _kategoriButonu3(double mesafe, String Kategori) {
    return ElevatedButton(
      onPressed: () {
        _showDialog(context); // Diyalog penceresini göster
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: konumaGoreKategori == Kategori
            ? AppColors.fosucIconColor
            : AppColors.imagePickerUsageBottomAppBarColor,
        minimumSize: const Size(0, 35),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
      child: Text(
        Kategori,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: konumaGoreKategori == Kategori
              ? AppColors.black
              : AppColors.white,
          letterSpacing: 0,
        ),
      ),
    );
  }

  // butonları oluşturan widget
  Widget _kategoriButonu(String kategori) {
    return ElevatedButton(
      onPressed: () {
        _kategoriSec(kategori);
        kategoriFiltrele();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _seciliKategori == kategori
            ? AppColors.fosucIconColor
            : AppColors.imagePickerUsageBottomAppBarColor,
        minimumSize: const Size(0, 35),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
      child: Text(
        kategori,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color:
              _seciliKategori == kategori ? AppColors.black : AppColors.white,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  final List<DocumentSnapshot> books;

  const SearchPage({Key? key, required this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitap Adıyla Ara'),
        backgroundColor: AppColors.imagePickerUsageAppBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextField(
          onChanged: (query) {
            // Kitap adına göre arama yap
            final List<DocumentSnapshot> filteredBooks = books.where((book) {
              final String bookName = book['Book Name'].toLowerCase();
              return bookName.contains(query.toLowerCase());
            }).toList();

            // Sonuçları göster
            // Örneğin: ListView.builder ile filteredBooks listesini gösterebilirsiniz
          },
          decoration: const InputDecoration(
            hintText: 'Kitap adını girin',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
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
