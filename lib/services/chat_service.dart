import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pau_ybs_kitap_paylasim_tez/models/message.dart';

class ChatService extends ChangeNotifier {
  //MESAJ GÖNDERME
  Future sendMassage(String receiverID, String text) async {
    //Güncel olarak uygulamayı kullanan kullanıcının bilgileri alındı.
    final String userID = FirebaseAuth.instance.currentUser!.uid;
    final Timestamp timeStamp = Timestamp.now();

    //Mesaj göndericinin id'si ile bilgileri alınır
    Map<String, dynamic> senderUserInfos = await FirebaseFirestore.instance
        .collection('kullaniciBilgileri')
        .where('id', isEqualTo: userID)
        .get()
        .then((querySnapshot) => querySnapshot.docs.first.data());

    //Mesaj alıcının id'si ile bilgileri alınır
    Map<String, dynamic> reciverUserInfos = await FirebaseFirestore.instance
        .collection('kullaniciBilgileri')
        .where('id', isEqualTo: receiverID)
        .get()
        .then((querySnapshot) => querySnapshot.docs.first.data());

    //2 kullanıcı uid'si + karakteri ile join metodu sayesinde kombinasyonlanır
    //Bu sayede her 2 kullanıcının bulunduğu eşsiz bir doc açılabilir
    List<String> usersIDCombination = [userID, receiverID];
    usersIDCombination
        .sort(); //Sort metodu sohbet odası kimliğinin herhangi 2 kişi için her zaman aynı olmasını sağlar çünkü aynı 2 uid kombinasyonu her zaman aynı şekilde sıralanabilir
    String messagingRoomID = usersIDCombination.join(
        "+"); //join fonksiyonu yardımıyla 2 ID + işaretiyle birleştirilir (ID+ID)

    //Message tipinden bir nesne oluşturarak yeni mesaj oluşturma
    Message newText = Message(
        mesajGonderenUserName: senderUserInfos['user_name'],
        mesajGonderenID: userID,
        mesajAlanID: receiverID,
        text: text,
        timeStamp: timeStamp,
        uidCombinationsString: messagingRoomID,
        //-------------------------------------------------
        senderProfilePhoto: senderUserInfos['profile_image'],
        senderUserSurname: senderUserInfos['user_surname'],
        senderEmail: senderUserInfos['email'],
        senderUserNickname: senderUserInfos['user_nickname'],
        //-------------------------------------------------
        reciverProfilePhoto: reciverUserInfos['profile_image'],
        reciverUserName: reciverUserInfos['user_name'],
        reciverUserSurname: reciverUserInfos['user_surname'],
        reciverEmail: reciverUserInfos['email'],
        reciverUserNickname: reciverUserInfos['user_nickname']);

    //Veri tabanına yeni mesaj ekleme
    await FirebaseFirestore.instance
        .collection('messaging')
        .doc(messagingRoomID)
        .collection('messages')
        .add(newText.convertMap());

    //Sadece kullanıcının içerisinde bulunduğu konuşmaları çekebilmek için oluşturulmuş olan contactList koleksiyonundan
    //uidCombinations sayesinde istenilen konuşmanın taraf bilgilerinin çekilmesini sağlar
    //Firebase yapısı sebebiyle filtreleme işlemini ancak bu şekilde yapabildim
    QuerySnapshot contactListSnapshot = await FirebaseFirestore.instance
        .collection('contactLists')
        .where('uidCombinations', isEqualTo: messagingRoomID)
        .get();

    //Eğer sorgulanan değer koleksiyon içinde yoksa, yani 2 insan daha önce bir konuşma başlatmamışsa
    //İki insan arasındaki kontak kurulur
    if (contactListSnapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('contactLists')
          .add(newText.convertArrayMapForContacts());
      print('Yeni veri eklendi');
    } else {
      print('Değer zaten mevcut');
    }
  }

  //MESAJ ALMA
  Stream<QuerySnapshot> getMessages(String userID, String receiverID) {
    //2 kullanıcı uid'si + karakteri ile join metodu sayesinde kombinasyonlanır
    //Bu sayede her 2 kullanıcının bulunduğu eşsiz bir doc açılabilir
    List<String> usersIDCombination = [userID, receiverID];
    usersIDCombination
        .sort(); //Sort metodu sohbet odası kimliğinin herhangi 2 kişi için her zaman aynı olmasını sağlar çünkü aynı 2 uid kombinasyonu her zaman aynı şekilde sıralanabilir
    String messagingRoomID = usersIDCombination.join(
        "+"); //join fonksiyonu yardımıyla 2 ID + işaretiyle birleştirilir (ID+ID)

    //descending=azalan
    //descending:false => artan sırayla demektir
    //bu sayede messaging koleksiyonundaki ilgili id içinde bulunan mesajlar kronolojik olarak sıralanır
    return FirebaseFirestore.instance
        .collection('messaging')
        .doc(messagingRoomID)
        .collection('messages')
        .orderBy('timeStamp', descending: false)
        .snapshots();
  }
}
