import 'package:flutter/material.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/add_books.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/home_page.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/map_screen.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/messaging_pages/search_users.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/profile_pages/profile_page.dart';
import '../../config/theme/app_colors.dart';

int pageIndex = 0;
int istenilenSayfa = 0;
Color indexColor = AppColors.imagePickerUsageBottomAppBarColor;
bool focusColor = false;

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.black,
      height: 77,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            left: 0,
            top: 5,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.imagePickerUsageBottomAppBarColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(children: [
                Expanded(
                    child: IconButton(
                  onPressed: () {
                    setState(() {
                      istenilenSayfa = 0;
                      if (istenilenSayfa == pageIndex) {
                      } else {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const HomePage(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                        //Navigator.of(context).popUntil((route) => route.isFirst);
                        setState(() {
                          pageIndex = 0;
                        });
                      }
                    });
                  },
                  icon: Image.asset(
                    'assets/icons/home.png',
                    height: 25,
                    width: 25,
                    color: pageIndex == 0
                        ? AppColors.fosucIconColor
                        : AppColors.iconColor,
                  ),
                )),
                Expanded(
                    child: IconButton(
                  onPressed: () {
                    setState(() {
                      int istenilenSayfa = 1;
                      if (istenilenSayfa == pageIndex) {
                      } else {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const MapPage(isComingFromHomePage: false,),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );

                        setState(() {
                          pageIndex = 1;
                        });
                      }
                    });
                  },
                  icon: Image.asset(
                    'assets/icons/map.png',
                    height: 25,
                    width: 25,
                    color: pageIndex == 1
                        ? AppColors.fosucIconColor
                        : AppColors.iconColor,
                  ),
                )),
                Expanded(
                    child: IconButton(
                  onPressed: () {
                    setState(() {
                      int istenilenSayfa = 2;
                      if (istenilenSayfa == pageIndex) {
                      } else {
                        Navigator.pushReplacement(
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
                        setState(() {
                          pageIndex = 2;
                        });
                      }
                    });
                  },
                  icon: Image.asset(
                    'assets/icons/chat.png',
                    height: 25,
                    width: 25,
                    color: pageIndex == 2
                        ? AppColors.fosucIconColor
                        : AppColors.iconColor,
                  ),
                )),
                Expanded(
                    child: IconButton(
                  onPressed: () {
                    setState(() {
                      int istenilenSayfa = 3;
                      if (istenilenSayfa == pageIndex) {
                      } else {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                const ImagePickerUsage(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                        setState(() {
                          pageIndex = 3;
                        });
                      }
                    });
                  },
                  icon: Image.asset(
                    'assets/icons/book.png',
                    height: 25,
                    width: 25,
                    color: pageIndex == 3
                        ? AppColors.fosucIconColor
                        : AppColors.iconColor,
                  ),
                )),
                Expanded(
                    child: IconButton(
                  onPressed: () {
                    setState(() {
                      int istenilenSayfa = 4;
                      if (istenilenSayfa == pageIndex) {
                      } else {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const ProfilePage(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                        setState(() {
                          pageIndex = 4;
                        });
                      }
                    });
                  },
                  icon: Image.asset(
                    'assets/icons/profile.png',
                    height: 25,
                    width: 25,
                    color: pageIndex == 4
                        ? AppColors.fosucIconColor
                        : AppColors.iconColor,
                  ),
                ))
              ]),
            ),
          ),
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   top: 0,
          //   child: Container(
          //     width: 64,
          //     height: 64,
          //     padding: EdgeInsets.all(17),
          //     decoration: BoxDecoration(
          //       boxShadow:[BoxShadow(
          //         color: Colors.black,
          //         blurRadius: 5,

          //         spreadRadius: 2,
          //       )],
          //       color: AppColors.imagePickerUsageBottomAppBarColor,
          //       shape: BoxShape.circle,
          //     ),
          //     child: Image.asset(
          //                   'assets/icons/home.png',
          //                   height: 30,
          //                   width: 30,
          //                   color: Color(0xffffd700),
          //                 ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
