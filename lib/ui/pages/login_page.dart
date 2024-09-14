// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/register_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/textfield.dart';
import '../../config/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _failController;
  late final AnimationController _loadingController;
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
    );

    _failController = AnimationController(
      vsync: this,
    );

    _loadingController = AnimationController(
      vsync: this,
    );

    //Animasyonların aynı sayfada 2. kez oynatılmasını sağlayan kodlar
    _failController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _failController.reset();
      }
    });

    _loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _loadingController.reset();
      }
    });
  }

  //Hafıza yönetimi sağlar, değişkenlerin yaşam döngüsü ile alakalı.
  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _logoController.dispose();
    _failController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  //Giriş yapma fonksiyonu (Ayrı dosyaya alınacak, customelevatedbuttona parametre olarak yollamanın yolunu bul)
  Future login() async {
    //kullanıcının giriş yapma durumunu ve bilgilerini bekleyen kısım.
    if (_loginEmailController.text.isEmpty ||
        _loginPasswordController.text.isEmpty) {
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
            title: Text("Hata!"),
            content: Text("Giriş bilgilerinizi tam doldurunuz."),
            actions: [
              TextButton(
                  onPressed: (() => Navigator.pop(context)),
                  child: Text("Geri Dön"))
            ],
          );
        },
      );
    } else if (_loginEmailController.text.isNotEmpty &&
        _loginPasswordController.text.isNotEmpty) {
      try {
        showDialog(
          context: context,
          builder: (context) {
            return Lottie.asset(
              'assets/animations/loading.json',
              controller: _loadingController,
              onLoaded: (composition) {
                _loadingController
                  ..duration = composition.duration
                  ..repeat();
              },
            );
          },
        );

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _loginEmailController.text.trim(),
          password: _loginPasswordController.text.trim(),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/homepage', // Ana sayfanın rotası
          (route) => false, // Tüm önceki rotaları kaldırır
        );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
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
              title: Text("Hata!"),
              content: Text(
                  "Lütfen giriş bilgilerinizin doğruluğunu kontrol ediniz. \n\n"
                  "${e.toString()}"),
              actions: [
                TextButton(
                    onPressed: (() => Navigator.pop(context)),
                    child: Text("Geri Dön"))
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Logo
              Lottie.asset(
                "assets/animations/login.json",
                height: 250,
                //width: MediaQuery.of(context).size.width,
                controller: _logoController,
                onLoaded: (composition) {
                  _logoController
                    ..duration = composition.duration
                    ..forward();
                  Future.delayed(Duration(milliseconds: 3000), () {
                    if (_logoController.isAnimating) {
                      _logoController.stop();
                    }
                  });
                },
              ),

              // Uygulama ismi
              Text(
                'WISDOM',
                style: TextStyle(
                  fontSize: 60,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),

              //E-mail input alanı
              CustomTextfield(
                fieldController: _loginEmailController,
                labelTextValue: 'E-Mail',
                horizontalValue: 33,
                color: Color.fromARGB(255, 217, 222, 238),
              ),
              //Şifre input alanı
              CustomTextfield(
                fieldController: _loginPasswordController,
                labelTextValue: 'Şifre',
                obscureTextValue: true,
                verticalValue: 5,
                horizontalValue: 33,
                color: Color.fromARGB(255, 217, 222, 238),
              ),

              SizedBox(
                height: 15,
              ),

              //Giriş yapma buttonu
              ElevatedButton(
                onPressed: () {
                  login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(230, 43),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                child: Text(
                  'Giriş Yap',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),

              SizedBox(
                height: 5,
              ),

              //Kayıt sayfasına yönendirme
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Henüz hesabın yok mu? ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800),
                  ),
                  GestureDetector(
                    onTap: () {
                      //Navigator.popUntil(context, ModalRoute.withName('/'));
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => RegisterPage(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Üye ol",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
