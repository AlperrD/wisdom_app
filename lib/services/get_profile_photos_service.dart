// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/profile_photos/get_profile_photos.dart';

class GetPhotosService extends StatefulWidget {
  final String? comingUserID;
  const GetPhotosService({super.key, this.comingUserID});

  @override
  State<GetPhotosService> createState() => _GetPhotosServiceState();
}

class _GetPhotosServiceState extends State<GetPhotosService> {
  // Database tarafından gelen verileri tutmak veri için bir Future<Map> nesnesi
  late Future<Map<String, String>> _imagePathsFuture;

  @override
  void initState() {
    super.initState();
    // Kullanıcı fotoğraflarını getiren asenkron fonksiyonu başlat
    _imagePathsFuture = getUserImagesPath();
  }

  // Firebase'den kullanıcının profil ve kapak fotoğrafı yollarını getiren asenkron fonksiyon
  Future<Map<String, String>> getUserImagesPath() async {
    // Başlangıçta boş profil ve kapak fotoğrafı yolları
    Map<String, String> imagePaths = {
      'profile_image': '',
      'cover_image': '',
    };

    try {
      // Firebase Firestore'dan kullaniciBilgileri/userID koleksiyonunu çek
      var snapshot;
      if (widget.comingUserID == null) {
        snapshot = await FirebaseFirestore.instance
            .collection('kullaniciBilgileri')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('kullaniciBilgileri')
            .doc(widget.comingUserID)
            .get();
      }

      // Eğer koleksiyonda veri varsa
      if (snapshot.exists) {
        // Firestore'dan alınan veriyi bir map olarak dataya ata
        final data = snapshot.data() as Map<String, dynamic>;

        // Eğer 'profile_image' varsa, değeri kullan, yoksa ''
        if (data.containsKey('profile_image')) {
          imagePaths['profile_image'] = data['profile_image'] ?? '';
        }

        // Eğer 'cover_image' varsa, değeri kullan, yoksa ''
        if (data.containsKey('cover_image')) {
          imagePaths['cover_image'] = data['cover_image'] ?? '';
        }
      }
    } catch (e) {
      // Hata durumunda konsola hata mesajını yazdır
      print('Kullanıcı fotoğraflarını alma hatası: $e');
    }

    // Profil ve kapak fotoğrafı yollarını içeren mapi döndür
    return imagePaths;
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder kullanarak Firebase'den gelen verileri gösterme
    return FutureBuilder<Map<String, String>>(
      future: _imagePathsFuture,
      builder: (context, snapshot) {
        // Veri bekleniyor durumunda dönen dairesel ilerleme göstergesi
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        // Hata durumunda hata mesajını gösterir
        else if (snapshot.hasError) {
          return Text('Hata: ${snapshot.error}');
        }
        // Veri yoksa veya boşsa ilgili mesajı gösterir
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Veri bulunamadı');
        }
        // Veri varsa, gelen profil ve kapak fotoğrafı yollarını kullanarak GetProfilePhotos widgetına parametre olarak yollar
        //Sonra GetProfilePhotos() sayfasını burada çağırıp çağrılan yere return eder
        else {
          Map<String, String> imagePaths = snapshot.data!;
          String profileImagePath = imagePaths['profile_image'] ?? '';
          String coverImagePath = imagePaths['cover_image'] ?? '';

          return GetProfilePhotos(
            profileImagePath: profileImagePath,
            coverImagePath: coverImagePath,
          );
        }
      },
    );
  }
}
