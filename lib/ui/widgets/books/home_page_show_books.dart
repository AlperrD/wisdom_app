import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:pau_ybs_kitap_paylasim_tez/services/screen_helper_service.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/map_screen.dart';
import '../../../config/theme/app_colors.dart';

class ShowBooksHomePage extends StatefulWidget {
  final String imageUrl;
  final String bookName;
  final String bookAuthor;
  final String userNickName;
  final String kategori;
  final double uzaklik;
  //-------------------
  final double latitude; //enlem
  final double longitude; //boylam
  final String description;
  final Timestamp date;
  final String addedPersonID;

  const ShowBooksHomePage(
      {Key? key,
      required this.imageUrl,
      required this.bookName,
      required this.bookAuthor,
      required this.userNickName,
      required this.kategori,
      required this.uzaklik,
      required this.latitude,
      required this.longitude,
      required this.description,
      required this.date,
      required this.addedPersonID})
      : super(key: key);

  @override
  State<ShowBooksHomePage> createState() => _ShowBooksHomePageState();
}

class _ShowBooksHomePageState extends State<ShowBooksHomePage>
    with TickerProviderStateMixin {
  late final AnimationController _failController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _failController = AnimationController(
      vsync: this,
    );

    //Animasyonların aynı sayfada 2. kez oynatılmasını sağlayan kodlar
    _failController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _failController.reset();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _failController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSizer sizer = ScreenSizer(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    double width = sizer.width;
    double height = sizer.height;

    return InkWell(
      onTap: () async {
        if (FirebaseAuth.instance.currentUser!.uid != widget.addedPersonID) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => MapPage(
                isComingFromHomePage: true,
                addedPersonID: widget.addedPersonID,
                bookAuthor: widget.bookAuthor,
                bookName: widget.bookName,
                date: widget.date,
                description: widget.description,
                imageUrl: widget.imageUrl,
                kategori: widget.kategori,
                latitude: widget.latitude,
                longitude: widget.longitude,
                userNickName: widget.userNickName,
                uzaklik: widget.uzaklik,
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
                content: Text("Kendi paylaştığınız kitabı talep edemezsiniz."),
                actions: [
                  TextButton(
                      onPressed: (() => Navigator.pop(context)),
                      child: Text("Geri Dön"))
                ],
              );
            },
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.imagePickerUsageAppBarColor,
            ),
            width: screenWidth * 0.89,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.imagePickerUsageAppBarColor,
                    ),
                    height: 100,
                    width: 130,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 1,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: Text(
                              widget.bookName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.imagePickerUsageTextFieldColor,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 5, left: width >= 310 ? 30 : 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget.kategori == 'Bilim Kurgu'
                                          ? Colors.green
                                          : widget.kategori == 'Polisiye'
                                              ? Colors.white
                                              : widget.kategori == 'Roman'
                                                  ? Colors.yellow
                                                  : widget.kategori ==
                                                          'Fantastik'
                                                      ? Colors.blue.shade200
                                                      : widget.kategori ==
                                                              'Korku'
                                                          ? Colors.purple
                                                          : widget.kategori ==
                                                                  'Tarih'
                                                              ? Colors.grey
                                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          widget.bookAuthor,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.imagePickerUsageTextFieldColor,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 1, top: 30),
                            child: SizedBox(
                              width: 80,
                              child: Text(
                                widget.userNickName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color:
                                      AppColors.imagePickerUsageTextFieldColor,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 24, top: 30),
                            child: SizedBox(
                              width: 70,
                              child: Text(
                                '~ ${widget.uzaklik >= 1000 ? (widget.uzaklik / 1000).toStringAsFixed(2) : widget.uzaklik.toStringAsFixed(2)} ${widget.uzaklik >= 1000 ? 'km' : 'm'}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color:
                                      AppColors.imagePickerUsageTextFieldColor,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
