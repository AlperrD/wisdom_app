import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String mesajGonderenUserName;
  final String mesajGonderenID;
  final String mesajAlanID;
  final String text;
  final Timestamp timeStamp;
  final String uidCombinationsString;
  //------------------------------------------
  final String senderProfilePhoto;
  final String senderUserSurname;
  final String senderEmail;
  final String senderUserNickname;
  //------------------------------------------
  final String reciverProfilePhoto;
  final String reciverUserName;
  final String reciverUserSurname;
  final String reciverEmail;
  final String reciverUserNickname;

  Message({
    required this.mesajGonderenUserName,
    required this.mesajGonderenID,
    required this.mesajAlanID,
    required this.text,
    required this.timeStamp,
    required this.uidCombinationsString,
    //--------------------------------------
    required this.senderProfilePhoto,
    required this.senderUserSurname,
    required this.senderEmail,
    required this.senderUserNickname,
    //--------------------------------------
    required this.reciverProfilePhoto,
    required this.reciverUserName,
    required this.reciverUserSurname,
    required this.reciverEmail,
    required this.reciverUserNickname,
  });

  //Messaging/uidCombinations/messages/mesaj içerikleri
  //Firebase tarafında bilgiler map formatında saklandığı için mape çevirme işlemi
  Map<String, dynamic> convertMap() {
    return {
      'senderUserName': mesajGonderenUserName,
      'senderID': mesajGonderenID,
      'receiverID': mesajAlanID,
      'text': text,
      'timeStamp': timeStamp,
    };
  }

  //contactLists/kontaklar/kontak içerikleri
  //Firebase tarafında bilgiler map formatında saklandığı için mape çevirme işlemi
  Map<String, dynamic> convertArrayMapForContacts() {
    return {
      'senderID': mesajGonderenID,
      'senderProfilePhoto': senderProfilePhoto,
      'senderUserName': mesajGonderenUserName,
      'senderUserSurname': senderUserSurname,
      'senderEmail': senderEmail,
      'senderUserNickname': senderUserNickname,
      'reciverID': mesajAlanID,
      'reciverProfilePhoto': reciverProfilePhoto,
      'reciverUserName': reciverUserName,
      'reciverUserSurname': reciverUserSurname,
      'reciverEmail': reciverEmail,
      'reciverUserNickname': reciverUserNickname,
      'uidCombinations': uidCombinationsString,
    };
  }
}
