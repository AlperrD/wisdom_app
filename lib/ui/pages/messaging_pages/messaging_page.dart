// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pau_ybs_kitap_paylasim_tez/config/theme/app_colors.dart';
import 'package:pau_ybs_kitap_paylasim_tez/services/chat_service.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/messaging_pages/%C4%B1nbox_messaging_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/message_bubble.dart';
import '../../widgets/textfield.dart';

class MessagingPage extends StatefulWidget {
  //Bu reciverID aslında contactList içinde konuşmanın tamamında ilk mesajı yollayanı ifade eder.
  //Çünkü değer kullanının mesaj yollayan mı alan mı olduğuna göre değişir.
  //Yani mesaj yollama fonksiyonunda aslında kişinin mesaj yollayan olduğu durumda mesajı yolladığı kişinin ıdsi,
  //mesajı alan kişi olduğu konumda ise mesajı yollayanın idsi bulunur
  //bunun sebebi anlık kullanıcıya göre karşı taraftakinin her zaman alıcı olmasıdır.
  final String reciverUserID;
  final String reciverUserNickName;

  const MessagingPage(
      {super.key,
      required this.reciverUserID,
      required this.reciverUserNickName});

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  // ignore: prefer_final_fields
  ScrollController _scrollController = ScrollController();

  void sendMessage() async {
    //Eğer birşey yazıldıysa mesajı gönderir
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMassage(
          widget.reciverUserID, _messageController.text);
      //Mesaj gönderildikten sonra conrtolleri temizleme
      _messageController.clear();
    }
  }

  //sayfanın en son mesajdan başlamasını sağlar
  void _goToBottomPage() {
    Future.delayed(const Duration(milliseconds: 400)).then((_) {
      try {
        _scrollController
            .animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        )
            .then((value) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });
      } catch (e) {
        // ignore: avoid_print
        print('SCROLL CONTROLLER ERROR: $e');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //Hata durumunda kullanılacak parametre => seconds: 1
    Future.delayed(Duration(milliseconds: 700), () {
      _goToBottomPage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatService.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.generalBackground,
      appBar: AppBar(
        toolbarHeight: 50,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
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
        title: Text(
          widget.reciverUserNickName,
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
      body: Column(
        children: [
          //Mesajlar
          Expanded(
            child: StreamBuilder(
              //veri kaynağı
              //.getMessages sayesinde ilgili konuşmanın mesajlarını çekilir
              stream: _chatService.getMessages(
                  FirebaseAuth.instance.currentUser!.uid, widget.reciverUserID),
              builder: (context, snapshot) {
                //Bağlantı sorunu varsa
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                //error durumunda (bu kısım popup ile değiltirilebilir)
                if (snapshot.hasError) {
                  return Center(child: Text("Birşeyler yanlış gitti."));
                }

                //İlgili messages koleksiyonun altında kaç adet mesaj varsa o kadar mesaj itemi oluşturulur
                return ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final document = snapshot.data!.docs[index];
                    return _buildMessageItem(document);
                  },
                );
              },
            ),
          ),
          //Mesaj gönderme alanı
          Row(
            children: [
              SizedBox(
                width: 5,
              ),
              //Metin kutusu
              Expanded(
                child: CustomTextfield(
                  fieldController: _messageController,
                  labelTextValue: 'Mesaj',
                  borderRadiusValue: 30,
                  containerHeight: 60,
                  horizontalValue: 5,
                  verticalValue: 10,
                  maxLines: 5,
                  maxLength: 200,
                  color: Color.fromARGB(255, 217, 222, 238),
                ),
              ),

              //Gönder butonu
              IconButton(
                onPressed: () {
                  sendMessage();
                  _goToBottomPage();
                },
                icon: Icon(
                  Icons.send_rounded,
                  size: 40,
                ),
                splashColor: AppColors.generalBackground,
              ),
            ],
          ),
        ],
      ),
    );
  }

  //Her mesaj itemının oluşturulmasını sağlar
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //Mesajları kullanıcıya göre sağa ve sola konumlandırma
    var alignment = (data['senderID'] == FirebaseAuth.instance.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            MessageBubble(
              message: data['text'],
              timeStamp: data['timeStamp'],
              isSentByMe: data['senderID'],
              user_nickname: data['senderUserName'],
            ),
          ],
        ),
      ),
    );
  }
}
