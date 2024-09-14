import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:pau_ybs_kitap_paylasim_tez/config/theme/app_colors.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/home_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';
import 'messaging_pages/messaging_page.dart';
import 'dart:ui' as ui;

class MapPage extends StatefulWidget {
  final bool isComingFromHomePage;
  final String? imageUrl;
  final String? bookName;
  final String? bookAuthor;
  final String? userNickName;
  final String? kategori;
  //final double? uzaklik;
  //-------------------
  final double? latitude; //enlem
  final double? longitude; //boylam
  final double? uzaklik;
  final String? description;
  final Timestamp? date;
  final String? addedPersonID;
  const MapPage(
      {super.key,
      required this.isComingFromHomePage,
      this.imageUrl,
      this.bookName,
      this.bookAuthor,
      this.userNickName,
      this.kategori,
      // this.uzaklik,
      this.latitude,
      this.longitude,
      this.description,
      this.date,
      this.addedPersonID,
      this.uzaklik});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng denizliMerkez = LatLng(37.754507, 29.105607);
  List<LatLng> bookLocations = [];
  List<String> bookNames = [];
  List<String> bookOwnersNickNames = [];
  final locationController = Location();
  LatLng? userCurrentPosition;
  bool _disposed = false;
  late BitmapDescriptor _markerIcon;
  //final Completer<GoogleMapController> _konrolcu = Completer();

  @override
  void initState() {
    super.initState();
    //UI renderlandıktan sonra çağrı yapılmasını sağlayan metod
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _markerIcon = await getBitmapDescriptorFromAssetBytes(
          "assets/icons/login_page_book.png", 100);
      await getBooksPositions();
      await getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _updateStateIfNotDisposed(LatLng newPosition) {
    if (!_disposed) {
      setState(() {
        userCurrentPosition = newPosition;
      });
    }
  }

  //-----------------------------------------------------------------------
  //https://github.com/flutter/flutter/issues/34657#issuecomment-615458858
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
      String path, int width) async {
    final Uint8List imageData = await getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(imageData);
  }
  //-----------------------------------------------------------------------

  getBooksPositions() async {
    await FirebaseFirestore.instance
        .collection('books')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (FirebaseAuth.instance.currentUser!.uid !=
            doc.data()['Person Who Added']) {
          setState(() {
            bookLocations
                .add(LatLng(doc.data()['Enlem'], doc.data()['Boylam']));
            bookNames.add(doc.data()['Book Name']);
            bookOwnersNickNames.add(doc.data()['UserNickname']);
          });
        }
      }
    });
  }

  // double deg2rad(double deg) {
  //   return deg * (pi / 180);
  // }

  // double uzaklikHesapla(double kitapEnlem, double kitapBoylam,
  //     double kullaniciEnlem, double kullaniciBoylam) {
  //   var R = 6371 * 1000; // Dünya'nın yarıçapı (metre cinsinden)
  //   var dEnlem = deg2rad(kullaniciEnlem - kitapEnlem);
  //   var dBoylam = deg2rad(kullaniciBoylam - kitapBoylam);

  //   var a = sin(dEnlem / 2) * sin(dEnlem / 2) +
  //       cos(deg2rad(kitapEnlem)) *
  //           cos(deg2rad(kullaniciEnlem)) *
  //           sin(dBoylam / 2) *
  //           sin(dBoylam / 2);

  //   var c = 2 * atan2(sqrt(a), sqrt(1 - a));
  //   var d = R * c; // Uzaklık metre cinsinden

  //   return d;
  // }

  Set<Marker> _createMarker(
      double? latitude,
      double? longitude,
      String? imageurl,
      String? bookName,
      String? bookAuthor,
      String? userNickName,
      String? kategori,
      String? description,
      Timestamp? date,
      String? addedPersonID,
      double? uzaklik) {
    LatLng coordinat = LatLng(latitude!, longitude!);
    List<Marker> markers = [];
    Marker chosenBookMarker = Marker(
        infoWindow: const InfoWindow(
          title: "Seçilen Konum",
          //snippet: bookOwnersNickNames[i],
        ),
        markerId: MarkerId(coordinat.toString()),
        position: coordinat,
        icon: _markerIcon,
        onTap: () {
          showModalBottomSheet(
            backgroundColor: AppColors.white,
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10.0,
                ),
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    const Text(
                      "Seçtiğiniz Konumda Bulunan Kitap",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                      color: Color(0xFF757575),
                      thickness: .7,
                      indent: 18,
                      endIndent: 18,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 7.0),
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: AppColors.imagePickerUsageAppBarColor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.network(
                                        imageurl!,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .3, // Resmin genişliği
                                        height:
                                            MediaQuery.of(context).size.width *
                                                .5, // Resmin yüksekliği
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  "Kitap Adı: ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    bookName!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Yazar: ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    bookAuthor!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Açıklama: ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    description!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Kitap Türü: ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    kategori!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Paylaşan: ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    userNickName!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Tarih: ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    DateFormat('dd.MM.yyyy')
                                                        .format(date!.toDate()),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Row(
                                            //   children: [
                                            //     const Text(
                                            //       "Uzaklık: ",
                                            //       style: TextStyle(
                                            //           color: Colors.white,
                                            //           fontSize: 16,
                                            //           fontWeight:
                                            //               FontWeight.bold),
                                            //     ),
                                            //     Expanded(
                                            //       child: Text(
                                            //         '~ ${widget.uzaklik! >= 1000 ? (widget.uzaklik! / 1000).toStringAsFixed(2) : widget.uzaklik!.toStringAsFixed(2)} ${widget.uzaklik! >= 1000 ? 'km' : 'm'}',
                                            //         style: const TextStyle(
                                            //           color: Colors.white,
                                            //           fontSize: 16,
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        MessagingPage(
                                                      reciverUserID:
                                                          addedPersonID!,
                                                      reciverUserNickName:
                                                          userNickName,
                                                    ),
                                                    transitionsBuilder: (_,
                                                        animation, __, child) {
                                                      return FadeTransition(
                                                        opacity: animation,
                                                        child: child,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                minimumSize:
                                                    const Size(200, 37),
                                                elevation: 0,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              child: const Text(
                                                'Talep Et',
                                                style: TextStyle(
                                                  fontSize: 23,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });

    markers.add(chosenBookMarker);
    markers.add(Marker(
      markerId: MarkerId(userCurrentPosition.toString()),
      position: userCurrentPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(260),
      onTap: () async {
        try {
          var selectedBooksInfos = await FirebaseFirestore.instance
              .collection('books')
              .where('Enlem', isEqualTo: userCurrentPosition!.latitude)
              .where('Boylam', isEqualTo: userCurrentPosition!.longitude)
              .get();

          List<Map<String, dynamic>> formattedSelectedBooksInfos =
              selectedBooksInfos.docs.map((review) => review.data()).toList();
          if (formattedSelectedBooksInfos.isNotEmpty) {
            showModalBottomSheet(
              backgroundColor: AppColors.white,
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 10.0,
                  ),
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const Text(
                        "Seçtiğiniz Konumda Bulunan Kitaplar",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        color: Color(0xFF757575),
                        thickness: .7,
                        indent: 18,
                        endIndent: 18,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: formattedSelectedBooksInfos.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 7.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: AppColors.imagePickerUsageAppBarColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          formattedSelectedBooksInfos[index]
                                              ['Image'],
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3, // Resmin genişliği
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5, // Resmin yüksekliği
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Kitap Adı: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Book Name']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Yazar: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Author']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Açıklama: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Description']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Kitap Türü: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Kategori']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Paylaşan: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['UserNickname']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Tarih: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      DateFormat('dd.MM.yyyy').format(
                                                          formattedSelectedBooksInfos[
                                                                      index][
                                                                  'Upload Date']
                                                              .toDate()),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder:
                                                          (_, __, ___) =>
                                                              MessagingPage(
                                                        reciverUserID:
                                                            formattedSelectedBooksInfos[
                                                                    index][
                                                                'Person Who Added'],
                                                        reciverUserNickName:
                                                            formattedSelectedBooksInfos[
                                                                    index][
                                                                'UserNickname'],
                                                      ),
                                                      transitionsBuilder: (_,
                                                          animation,
                                                          __,
                                                          child) {
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  minimumSize:
                                                      const Size(200, 37),
                                                  elevation: 0,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Talep Et',
                                                  style: TextStyle(
                                                    fontSize: 23,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        } on Exception catch (_) {
          print('ERROR: $_');
        }
      },
      infoWindow: const InfoWindow(
        title: "Güncel Konumunuz",
        //snippet: bookOwnersNickNames[i],
      ),
    ));
    return markers.toSet();
  }

  Set<Marker> _createMarkers() {
    List<Marker> markers = [];

    for (int i = 0; i < bookLocations.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId(bookLocations[i].toString()),
          position: bookLocations[i],
          icon: _markerIcon,
          onTap: () async {
            var selectedBooksInfos = await FirebaseFirestore.instance
                .collection('books')
                .where('Enlem', isEqualTo: bookLocations[i].latitude)
                .where('Boylam', isEqualTo: bookLocations[i].longitude)
                .get();

            List<Map<String, dynamic>> formattedSelectedBooksInfos =
                selectedBooksInfos.docs.map((review) => review.data()).toList();
            showModalBottomSheet(
              backgroundColor: AppColors.white,
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 10.0,
                  ),
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const Text(
                        "Seçtiğiniz Konumda Bulunan Kitaplar",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        color: Color(0xFF757575),
                        thickness: .7,
                        indent: 18,
                        endIndent: 18,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: formattedSelectedBooksInfos.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 7.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: AppColors.imagePickerUsageAppBarColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          formattedSelectedBooksInfos[index]
                                              ['Image'],
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3, // Resmin genişliği
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5, // Resmin yüksekliği
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Kitap Adı: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Book Name']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Yazar: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Author']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Açıklama: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Description']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Kitap Türü: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Kategori']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Paylaşan: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['UserNickname']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              // Row(
                                              //   children: [
                                              //     const Text(
                                              //       "Uzaklık: ",
                                              //       style: TextStyle(
                                              //           color: Colors.white,
                                              //           fontSize: 16,
                                              //           fontWeight:
                                              //               FontWeight.bold),
                                              //     ),
                                              //     Expanded(
                                              //       child: Text(
                                              //         '~ ${widget.uzaklik! >= 1000 ? (widget.uzaklik! / 1000).toStringAsFixed(2) : widget.uzaklik!.toStringAsFixed(2)} ${widget.uzaklik! >= 1000 ? 'km' : 'm'}',
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder:
                                                          (_, __, ___) =>
                                                              MessagingPage(
                                                        reciverUserID:
                                                            formattedSelectedBooksInfos[
                                                                    index][
                                                                'Person Who Added'],
                                                        reciverUserNickName:
                                                            formattedSelectedBooksInfos[
                                                                    index][
                                                                'UserNickname'],
                                                      ),
                                                      transitionsBuilder: (_,
                                                          animation,
                                                          __,
                                                          child) {
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  minimumSize:
                                                      const Size(200, 37),
                                                  elevation: 0,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Talep Et',
                                                  style: TextStyle(
                                                    fontSize: 23,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          infoWindow: const InfoWindow(
            title: "Seçilen Konum",
            //snippet: bookOwnersNickNames[i],
          ),
        ),
      );
    }

    markers.add(Marker(
      markerId: MarkerId(userCurrentPosition.toString()),
      position: userCurrentPosition!,
      //260
      icon: BitmapDescriptor.defaultMarkerWithHue(260),
      onTap: () async {
        try {
          var selectedBooksInfos = await FirebaseFirestore.instance
              .collection('books')
              .where('Enlem', isEqualTo: userCurrentPosition!.latitude)
              .where('Boylam', isEqualTo: userCurrentPosition!.longitude)
              .get();

          List<Map<String, dynamic>> formattedSelectedBooksInfos =
              selectedBooksInfos.docs.map((review) => review.data()).toList();
          if (formattedSelectedBooksInfos.isNotEmpty) {
            showModalBottomSheet(
              backgroundColor: AppColors.white,
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 10.0,
                  ),
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const Text(
                        "Seçtiğiniz Konumda Bulunan Kitaplar",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        color: Color(0xFF757575),
                        thickness: .7,
                        indent: 18,
                        endIndent: 18,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: formattedSelectedBooksInfos.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 7.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: AppColors.imagePickerUsageAppBarColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          formattedSelectedBooksInfos[index]
                                              ['Image'],
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3, // Resmin genişliği
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5, // Resmin yüksekliği
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Kitap Adı: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Book Name']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Yazar: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Author']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Açıklama: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Description']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Kitap Türü: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['Kategori']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Paylaşan: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${formattedSelectedBooksInfos[index]['UserNickname']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Tarih: ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      DateFormat('dd.MM.yyyy').format(
                                                          formattedSelectedBooksInfos[
                                                                      index][
                                                                  'Upload Date']
                                                              .toDate()),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder:
                                                          (_, __, ___) =>
                                                              MessagingPage(
                                                        reciverUserID:
                                                            formattedSelectedBooksInfos[
                                                                    index][
                                                                'Person Who Added'],
                                                        reciverUserNickName:
                                                            formattedSelectedBooksInfos[
                                                                    index][
                                                                'UserNickname'],
                                                      ),
                                                      transitionsBuilder: (_,
                                                          animation,
                                                          __,
                                                          child) {
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  minimumSize:
                                                      const Size(200, 37),
                                                  elevation: 0,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Talep Et',
                                                  style: TextStyle(
                                                    fontSize: 23,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        } on Exception catch (_) {
          print('ERROR: $_');
        }
      },
      infoWindow: const InfoWindow(
        title: "Güncel Konumunuz",
        //snippet: bookOwnersNickNames[i],
      ),
    ));
    return markers.toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isComingFromHomePage == false) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          title: const Text(
            'Harita',
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
        body: Padding(
          padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.height * 0.005,
              left: MediaQuery.of(context).size.height * 0.005,
              // bottom: MediaQuery.of(context).size.width * 0.07,
              top: MediaQuery.of(context).size.width * 0.02),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: userCurrentPosition == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: denizliMerkez,
                        // zoom: 12.4,
                      ),
                      onMapCreated: (GoogleMapController controller) async {
                        await controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: denizliMerkez,
                              zoom: 12.4, // Hedef zoom seviyesi
                            ),
                          ),
                        );
                      },
                      polylines: {},
                      markers: _createMarkers(),
                    ),
            ),
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     //getBooksPositions();
        //   },
        //   label: const Text('To the lake!'),
        //   icon: const Icon(Icons.directions_boat),
        // ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          title: const Text(
            'Harita',
            style: TextStyle(
                color: AppColors.white,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 23,
                letterSpacing: 1),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HomePage(),
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
        body: Padding(
          padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.height * 0.005,
              left: MediaQuery.of(context).size.height * 0.005,
              // bottom: MediaQuery.of(context).size.width * 0.07,
              top: MediaQuery.of(context).size.width * 0.02),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: userCurrentPosition == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(widget.latitude!, widget.longitude!),
                        //zoom: 14,
                      ),
                      onMapCreated: (GoogleMapController controller) async {
                        await controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target:
                                  LatLng(widget.latitude!, widget.longitude!),
                              zoom: 16, // Hedef zoom seviyesi
                            ),
                          ),
                        );
                      },
                      polylines: {},
                      markers: _createMarker(
                          widget.latitude,
                          widget.longitude,
                          widget.imageUrl,
                          widget.bookName,
                          widget.bookAuthor,
                          widget.userNickName,
                          widget.kategori,
                          widget.description,
                          widget.date,
                          widget.addedPersonID,
                          widget.uzaklik),
                    ),
            ),
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     //getBooksPositions();
        //   },
        //   label: const Text('To the lake!'),
        //   icon: const Icon(Icons.directions_boat),
        // ),
      );
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    try {
      serviceEnabled = await locationController.serviceEnabled();

      //Konum hizmeti açma
      if (serviceEnabled) {
        serviceEnabled = await locationController.requestService();
      } else {
        return;
      }

      //Güncel konum alma
      permissionGranted = await locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await locationController.requestPermission();
        //konum izni verilmediyse
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      //Lokasyon değişikliklerini dinleme
      locationController.onLocationChanged.listen((currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          if (mounted) {
            setState(() {
              userCurrentPosition =
                  LatLng(currentLocation.latitude!, currentLocation.longitude!);
            });
            print(currentLocation);
          }
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Hata!"),
            content: Text('Hata : $e'),
            actions: [
              TextButton(
                  onPressed: (() => Navigator.pop(context)),
                  child: const Text("Geri Dön"))
            ],
          );
        },
      );
    }
  }

  // Future<List<LatLng>> getPolylinePoints() async {
  //    final polylinePoints = PolylinePoints();

  //   final result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleMapsApiKey,
  //     PointLatLng(googlePlex.latitude, googlePlex.longitude),
  //     PointLatLng(mountainView.latitude, mountainView.longitude),
  //   );
  // }
}
