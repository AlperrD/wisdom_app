import "dart:async";
import "package:flutter/material.dart";
import "package:lottie/lottie.dart";
import "package:pau_ybs_kitap_paylasim_tez/services/login_auth_controller_service.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() {
    var duration = Duration(milliseconds: 3000);
    return Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginController(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin:
                  const Offset(1.0, 0.0), // Başlangıç pozisyonu (sağa kaydır)
              end: Offset.zero, // Bitiş pozisyonu (hedef konum)
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.decelerate, // Geçişi yavaşlatan eğri
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 222, 238),
      body: animation(),
    );
  }

  Widget animation() {
    return Center(
      child: Container(
        child: Lottie.asset(
          "assets/animations/splash.json",
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.4,
        ),
      ),
    );
  }
}
