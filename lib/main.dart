import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/home_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/splash.dart';
import 'package:provider/provider.dart';
import 'services/login_auth_controller_service.dart';
import 'services/photo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Appi initialize etmek için firebase tarafını bekliyor.
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        // your firebase options.
        ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Urbanist'),
        //initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/welcome': (context) => LoginController(),
          '/homepage': (context) => HomePage(),
        },
        //home: LoginController(),
      ),
    );
  }
}
