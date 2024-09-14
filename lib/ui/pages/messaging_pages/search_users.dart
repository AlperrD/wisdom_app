// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pau_ybs_kitap_paylasim_tez/config/theme/app_colors.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/messaging_pages/%C4%B1nbox_messaging_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/profile_pages/profile_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';
import 'messaging_page.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  String name = '';
  List<String> fullNamesList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.generalBackground,
      bottomNavigationBar: CustomNavigationBar(),
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: const Text(
          'Kullanıcı Arama',
          style: TextStyle(
              color: AppColors.white,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
              fontSize: 23,
              letterSpacing: 1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Navigator.push(
           
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const InboxMessagingPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
              },
              icon: const Icon(Icons.mail_rounded),
              color: Colors.white,
              iconSize: 35,
            ),
          )
        ],
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
        Expanded(child: buildUsersList(name)),
      ]),
    );
  }

//---------------------------------------------------------------------------
  //Kullanıcının kendisi haricinde tüm diğer kullanıcıların bulunduğu bir liste inşa eder
  Widget buildUsersList(String name) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("kullaniciBilgileri")
            .snapshots(),
        builder: (context, snapshot) {
          //Bağlantı sorunu varsa
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          //error durumunda (bu kısım popup ile değiltirilebilir)
          if (snapshot.hasError) {
            return Center(child: Text("Birşeyler yanlış gitti."));
          }
          

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              //Search bar boş ise tüm kullanıcılar listelenir
              String fullName = data['user_name'] + " " + data['user_surname'];
              if (name.isEmpty) {
                return _buildUserListListItem(document);
              }
              //Girdiye göre isimleri filtreler ve sadece ilgili itemları yaratır
              if (fullName.toString().toLowerCase().contains(name.toLowerCase())) {
            return _buildUserListListItem(document);
          }
              return Container();
            },
          );
        });
  }

  Widget _buildUserListListItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    String profilePhoto = data['profile_image'].toString();

    //Kullanıcının kendisi haricinde tüm kullanıcıları listelemeyi sağlayan şart
    if (FirebaseAuth.instance.currentUser!.uid != data['id']) {
      return Column(children: [
        Padding(
          padding: EdgeInsets.only(right: 8, left: 8),
          child: Container(
            width: MediaQuery.of(context).size.height * 0.5,
            height: MediaQuery.of(context).size.height * 0.11,
            decoration: BoxDecoration(
              color: AppColors
                  .imagePickerUsageAppBarColor, // Transparent arka plan
              borderRadius: BorderRadius.circular(15), // Köşeleri yuvarlat
              //border:
              //    Border.all(color: Colors.black, width: 2), // Siyah çerçeve
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // 3D gölge efekti
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Gölgelendirme yönü
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.generalBackground,
                backgroundImage: NetworkImage(profilePhoto),
              ),
              title: Text(
                data['user_name'] + " " + data['user_surname'],
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.white),
              ),
              // subtitle: Text(
              //   data['user_nickname'],
              //   style: const TextStyle(
              //       fontSize: 15,
              //       fontWeight: FontWeight.w400,
              //       letterSpacing: 1,
              //       color: Colors.white),
              // ),
              onTap: () {
                Navigator.push(
           
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => MessagingPage(
                        
                        reciverUserNickName: data['user_nickname'],
                        reciverUserID: data['id'],
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
              
              trailing: IconButton(
                icon: Icon(
                  Icons.assignment_ind_rounded,
                  size: 40,
                ),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          comingUserID: data['id'],
                        ),
                      ));
                },
              ),
              // isThreeLine: true,
              dense: true,
            ),
          ),
        ),
        SizedBox(
          height: 13,
        ),
      ]);
    } else {
      //birşey yoksa
      return Container();
    }
  }
}
