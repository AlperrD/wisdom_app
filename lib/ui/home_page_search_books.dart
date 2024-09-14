// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:pau_ybs_kitap_paylasim_tez/config/theme/app_colors.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/home_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/map_screen.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/messaging_pages/%C4%B1nbox_messaging_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/profile_pages/profile_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';

class SearchBooksPage extends StatefulWidget {
  const SearchBooksPage({
    super.key,
  });

  @override
  State<SearchBooksPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchBooksPage>
    with TickerProviderStateMixin {
  String name = '';
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
    return Scaffold(
      backgroundColor: AppColors.generalBackground,
      bottomNavigationBar: CustomNavigationBar(),
      appBar: AppBar(
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
        toolbarHeight: 50,
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: const Text(
          'Kitap Arama',
          style: TextStyle(
              color: AppColors.white,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
              fontSize: 23,
              letterSpacing: 1),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: IconButton(
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) => const InboxMessagingPage()),
        //         );
        //       },
        //       icon: const Icon(Icons.mail_rounded),
        //       color: Colors.white,
        //       iconSize: 35,
        //     ),
        //   )
        // ],
        elevation: 20,
        backgroundColor: AppColors.imagePickerUsageAppBarColor,
      ),
      body: Column(children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 10, bottom: 5, right: 20, left: 20),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Ara',
            ),
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Expanded(child: buildBooksList(name)),
      ]),
    );
  }

  // This method builds a list of books excluding the current user's books
  Widget buildBooksList(String name) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("books").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Something went wrong."));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final document = snapshot.data!.docs[index];
            Map<String, dynamic> data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            //liste boş ise tüm listeyi çek
            if (name.isEmpty) {
              return _buildBookListListItem(document);
            }
            //kücük harfe uyarlayıp filtrele.
            if (data['Book Name']
                .toString()
                .toLowerCase()
                .contains(name.toLowerCase())) {
              return _buildBookListListItem(document);
            }
            return Container();
          },
        );
      },
    );
  }

  Widget _buildBookListListItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    String bookCoverUrl = data['Image'].toString();

    //kendi ekledikleri hariç tüm kitapları göster. Sonradan değiştirilebilir. Alper.
    if (FirebaseAuth.instance.currentUser!.uid != data['UploaderID']) {
      return Column(children: [
        Padding(
          padding: EdgeInsets.only(right: 8, left: 8),
          child: Container(
            width: MediaQuery.of(context).size.height * 0.5,
            height: MediaQuery.of(context).size.height * 0.11,
            decoration: BoxDecoration(
              color: AppColors.imagePickerUsageAppBarColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.generalBackground,
                backgroundImage: NetworkImage(bookCoverUrl),
              ),
              title: Text(
                data['Book Name'],
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.white),
              ),
              subtitle: Text(
                data['Author'],
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                    color: Colors.white),
              ),
              onTap: () async {
                if (FirebaseAuth.instance.currentUser!.uid !=
                    data['Person Who Added']) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => MapPage(
                        isComingFromHomePage: true,
                        imageUrl: data['Image'],
                        bookName: data['Book Name'],
                        bookAuthor: data['Author'],
                        userNickName: data['UserNickname'],
                        kategori: data['Kategori'],
                        //uzaklik: uzaklik,
                        latitude: data['Enlem'],
                        longitude: data['Boylam'],
                        description: data['Description'],
                        date: data['Upload Date'],
                        addedPersonID: data['Person Who Added'],
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
                        content: Text(
                            "Kendi paylaştığınız kitabı talep edemezsiniz."),
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
              trailing: Icon(
                Icons.book,
                size: 40,
                color: Colors.white,
              ),
              dense: true,
            ),
          ),
        ),
        SizedBox(
          height: 13,
        ),
      ]);
    } else {
      return Container();
    }
  }
}
