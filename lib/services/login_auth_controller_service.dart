// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/login_page.dart';

//Kullanıcının giriş yapma durumunu kontrol eden sayfa.
class LoginController extends StatefulWidget {
  const LoginController({super.key});

  @override
  State<LoginController> createState() => _LoginControllerState();
}

class _LoginControllerState extends State<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Streambuilder => Giriş yapma sayfasında kullanıcının girdiği bilgileri dinleme ve ona göre aksiyon alma.
      body: StreamBuilder<User?>(
        //Login yapılıp yapılmadığını dinler
        stream: FirebaseAuth.instance.authStateChanges(),
        //snapshot => user bilgileri
        builder: (context, snapshot) {
          //Bağlantı sorunu varsa
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          //error durumunda (bu kısım popup ile değiltirilebilir)
          else if (snapshot.hasError) {
            return Center(
                child: Text("Birşeyler yanlış gitti.(Snapshot has error)"));
          }
          //snapshot data içeriyorsa
          else if (snapshot.hasData) {
            //addPostFrameCallBack return container işlemi gerçekleştirildikten sonra çalışır ve
            //return edilen sayfa oluşturulduktan sonra {} içindeki ilgili kod parçacığını çalıştırır
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/homepage',
                (route) => false, // Tüm önceki rotaları kaldırır
              );
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(builder: (context) => HomePage()),
              // );
            });
            return Container();
          }
          //snapshot data içermiyorsa
          else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
