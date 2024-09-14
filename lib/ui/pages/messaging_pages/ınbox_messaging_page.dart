// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pau_ybs_kitap_paylasim_tez/config/theme/app_colors.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/messaging_pages/search_users.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';
import '../profile_pages/profile_page.dart';
import 'messaging_page.dart';

class InboxMessagingPage extends StatefulWidget {
  const InboxMessagingPage({super.key});

  @override
  State<InboxMessagingPage> createState() => _InboxMessagingPageState();
}

class _InboxMessagingPageState extends State<InboxMessagingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.generalBackground,
      bottomNavigationBar: CustomNavigationBar(),
      appBar: AppBar(
        toolbarHeight: 50,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const SearchUsersPage(),
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
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: const Text(
          'Mesajlar',
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
      body: buildConversations(),
    );
  }

  //Kurulmuş tüm sohbetlerin bilgilerini contactLists'ten çekip,
  //Bu sohbetlerde bulunan uidCombination alanında current userın UID'sini içerenleri filtreler,
  //Bu bilgilerle ilgili widgetları oluşturur
  Widget buildConversations() {
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('contactLists').snapshots(),
        builder: (context, snapshot) {
          //Bağlantı sorunu varsa
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          //error durumunda (bu kısım popup ile değiltirilebilir)
          if (snapshot.hasError) {
            return Center(child: Text("Birşeyler yanlış gitti."));
          }

          /* int itemCount = 0;

          if (snapshot.hasData) {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              data = snapshot.data!.docs[i].data() as Map<String, dynamic>;

              if (data['uidCombinations'].toString().contains(currentUserID)) {
                itemCount++;
              }
            }
          } */

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              if (data['uidCombinations'].toString().contains(currentUserID)) {
                return _buildConversationsListItem(data);
              }
              return Container();
            },
          );
        });
  }

  //Listview buildera verilecek her bir itemi gelen datalarla oluşturur.
  Widget _buildConversationsListItem(Map<String, dynamic> data) {
    //Anlık kullanıcının alıcı olduğu mesajlarda çalışır
    //Mesaj geldiyse gönderici bilgileri gösterilir
    if (data['reciverID']
        .toString()
        .contains(FirebaseAuth.instance.currentUser!.uid)) {
      return Column(children: [
        SizedBox(
          height: 13,
        ),
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
                backgroundImage:
                    NetworkImage(data['senderProfilePhoto'].toString()),
              ),
              title: Text(
                data['senderUserName'] + " " + data['senderUserSurname'],
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.white),
              ),
              // subtitle: Text(
              //   data['senderUserNickname'],
              //   style: const TextStyle(
              //       fontSize: 15.5,
              //       fontWeight: FontWeight.w400,
              //       letterSpacing: 1,
              //       color: Colors.white),
              // ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagingPage(
                        //kullanıcı mesaj alıcıysa karşı taraftaki yollayandır,
                        //ancak her zaman karşı taraftaki insan kullanıcının kendisine göre mesaj alıcıdır,
                        //bu sebeple alıcı id bu durumda mesajı yollanın id'sidir
                        //yani sistem anlık kullanıcıya göre şekil alır
                        reciverUserID: data['senderID'],
                        reciverUserNickName: data['senderUserNickname'],
                      ),
                    ));
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
                          comingUserID: data['senderID'],
                        ),
                      ));
                },
              ),
              //isThreeLine: true,
              dense: true,
            ),
          ),
        ),
      ]);
    }
    //Anlık kullanıcının gönderici olduğu mesajlarda çalışır
    //Mesaj atıldıysa alıcının bilgileri gösterilir
    else if (data['senderID']
        .toString()
        .contains(FirebaseAuth.instance.currentUser!.uid)) {
      return Column(children: [
        SizedBox(
          height: 13,
        ),
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
                backgroundImage:
                    NetworkImage(data['reciverProfilePhoto'].toString()),
              ),
              title: Text(
                data['reciverUserName'] + " " + data['reciverUserSurname'],
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.white),
              ),
              // subtitle: Text(
              //   data['reciverUserNickname'],
              //   style: const TextStyle(
              //       fontSize: 15.5,
              //       fontWeight: FontWeight.w400,
              //       letterSpacing: 1,
              //       color: Colors.white),
              // ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagingPage(
                        //kullanıcı mesaj yollayıcıysa karşı taraftaki mesaj alıcıdır,
                        //ancak her zaman karşı taraftaki insan kullanıcının kendisine göre ona mesaj yollayandır,
                        //bu sebeple mesaj yollayıcı id bu durumda mesajı alanın id'sidir
                        //yani sistem anlık kullanıcıya göre şekil alır
                        reciverUserID: data['reciverID'],
                        reciverUserNickName: data['reciverUserNickname'],
                      ),
                    ));
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
                          comingUserID: data['reciverID'],
                        ),
                      ));
                },
              ),
              //isThreeLine: true,
              dense: true,
            ),
          ),
        ),
      ]);
    } else {
      return Container();
    }
  }
}
