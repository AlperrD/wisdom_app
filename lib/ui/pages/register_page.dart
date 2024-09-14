// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/create_profile.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/login_page.dart';
import '../../config/theme/app_colors.dart';
import '../widgets/textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _confirmRegisterPasswordController =
      TextEditingController();
  late final AnimationController _loadingController;
  late final AnimationController _failController;
  bool isUserCreated = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
    );
    _failController = AnimationController(
      vsync: this,
    );

    _failController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _failController.reset();
      }
    });
  }

  //Hafıza yönetimi sağlar, değişkenlerin yaşam döngüsü ile alakalı.
  @override
  void dispose() {
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _confirmRegisterPasswordController.dispose();
    _loadingController.dispose();
    _failController.dispose();
    super.dispose();
  }

  //Kayıt olma fonksiyonu (Ayrı dosyaya alınacak, customelevatedbuttona parametre olarak yollamanın yolunu bul).
  Future register() async {
    //text => Değere string olarak erişimimizi sağlar.
    //trim => Başta ve sonda olabilecek boşlukları temizler.

    if (_registerEmailController.text.isNotEmpty &&
        _registerPasswordController.text.isNotEmpty &&
        _confirmRegisterPasswordController.text.isNotEmpty) {
      if (checkPasswords()) {
        isUserCreatedFun();
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
              title: const Text("Hata!"),
              content: const Text('Şifreleriniz eşleşmiyor.'),
              actions: [
                TextButton(
                    onPressed: (() => Navigator.pop(context)),
                    child: const Text("Geri Dön"))
              ],
            );
          },
        );
      }
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
            title: const Text("Hata!"),
            content: const Text("Kullanıcı bilgilerinizi tam doldurunuz."),
            actions: [
              TextButton(
                  onPressed: (() => Navigator.pop(context)),
                  child: const Text("Geri Dön"))
            ],
          );
        },
      );
    }
  }

  // //Girilen iki şifreninde aynı olup olmadığını kontrol eden metod.
  bool checkPasswords() {
    if (_registerPasswordController.text.trim() ==
        _confirmRegisterPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  void isUserCreatedFun() {
    setState(() {
      isUserCreated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.generalBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hesap Oluştur',
                style: GoogleFonts.bebasNeue(fontSize: 30),
              ),

              const Divider(
                color: Colors.black,
                thickness: 0.5,
                indent: 40,
                endIndent: 40,
              ),

              //E-mail input alanı
              CustomTextfield(
                  fieldController: _registerEmailController,
                  labelTextValue: 'E-Mail'),
              //Şifre input alanı
              CustomTextfield(
                  fieldController: _registerPasswordController,
                  labelTextValue: 'Şifre',
                  obscureTextValue: true),

              //Şifre doğrulama input alanı
              CustomTextfield(
                  fieldController: _confirmRegisterPasswordController,
                  labelTextValue: 'Tekrar şifre',
                  obscureTextValue: true),

              //Kayıt ol butonu
              ElevatedButton(
                onPressed: () async {
                  await register();
                  if (isUserCreated) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => CreateProfile(
                          createProfileEmail:
                              _registerEmailController.text.trim().toString(),
                          createProfilePassword: _registerPasswordController
                              .text
                              .trim()
                              .toString(),
                        ),
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0,
                                  0.0), // Başlangıç pozisyonu (sağa kaydır)
                              end: Offset.zero, // Bitiş pozisyonu (hedef konum)
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve:
                                  Curves.decelerate, // Geçişi yavaşlatan eğri
                            )),
                            child: child,
                          );
                        },
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(230, 43),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                child: const Text(
                  'Kayıt ol',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              //Giriş yap ekranına yönlendirme
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hesabın var mı? ",
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
                          pageBuilder: (_, __, ___) => LoginPage(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: const Text(
                      "Giriş Yap",
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
