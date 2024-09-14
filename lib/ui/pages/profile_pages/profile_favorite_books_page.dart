import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pau_ybs_kitap_paylasim_tez/config/theme/app_colors.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/pages/profile_pages/profile_page.dart';

import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/books/profile_added_books.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/button_navigation_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../services/firestore_services.dart';

// ignore: must_be_immutable
class FavoriteBookListPage extends StatefulWidget {
  final String? comingUserID;

  // Diğer ekrandan bu sayfanın oluşturulması için gönderilen kitap verilerini tutan liste.
  List<QueryDocumentSnapshot> books;
  FavoriteBookListPage({super.key, required this.books, this.comingUserID});

  @override
  // ignore: library_private_types_in_public_api
  _FavoriteBookListPageState createState() => _FavoriteBookListPageState();
}

class _FavoriteBookListPageState extends State<FavoriteBookListPage> {
  @override
  Widget build(BuildContext context) {
    Future<void> _deleteBook(var bookid) async {
      final bookref = firestore.collection('favorite_books').doc(bookid);

      await bookref
          .delete()
          // Silme işlemi başarılı olduğunda.
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kitap başarıyla silindi!'))))
          // Silme işlemi başarısız olduğunda.
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Kitap silinirken bir hata oluştu: $error'))));

      //silinen verinin ekrandan gitmesi için oluşturulan setState.
      setState(() {
        widget.books.removeWhere((book) => book.id == bookid);
      });
    }

    Future<void> _updateBook(String bookId) async {
      //Seçilen kitabı books listesinden 'book.id' göre bulma.
      final book = widget.books.firstWhere((book) => book.id == bookId);

      // Kitabın mevcut bilgilerini tutan ve değişime uğrayacak değişkenler.
      String newName = book['Book Name'];
      String newAuthor = book['Author'];
      String newDescription = book['Description'];
      String newYear = book['Year Of Publication'];
      String newPhoto = book['Image'];

      // Kitabın yeni bilgilerini almak için kullanılacak TextEditingController'lar
      TextEditingController nameController =
          TextEditingController(text: newName);
      // TextEditingController imageController =
      //     TextEditingController(text: newPhoto);
      TextEditingController descriptionController =
          TextEditingController(text: newDescription);
      TextEditingController yearController =
          TextEditingController(text: newYear);
      TextEditingController authorController =
          TextEditingController(text: newAuthor);

      //Ekranın ortasında oluşturulan dialog widgeti.
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Kitabı Düzenle'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // Kitabın adını almak için bir TextField widget
                  // TextField(
                  //   controller: authorController,
                  //   decoration: InputDecoration(labelText: 'Kitap Resmi'),
                  //   onChanged: (value) {
                  //     // Değişikliği newAuthor değişkenine kaydedin
                  //     newAuthor = value;
                  //   },
                  // ),

                  //Kitapların yeni bilgilerini kullanıcıdan alan ve yeni değişkenlere aktaran textfieldlar.
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Kitap Adı'),
                    onChanged: (value) {
                      newName = value;
                    },
                  ),
                  TextField(
                    controller: authorController,
                    decoration:
                        const InputDecoration(labelText: 'Kitap Yazarı'),
                    onChanged: (value) {
                      newAuthor = value;
                    },
                  ),
                  TextField(
                    controller: yearController,
                    decoration: const InputDecoration(labelText: 'Kitap Yılı'),
                    onChanged: (value) {
                      newYear = value;
                    },
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Kitap Açıklaması'),
                    onChanged: (value) {
                      newDescription = value;
                    },
                  ),

                  // Kitabın yeni fotoğrafını almak için kullanılacak kısım
                ],
              ),
            ),
            actions: [
              //Güncelleme işlemleri için oluşturulan butonlar.
              TextButton(
                child: const Text('Güncelle'),
                onPressed: () async {
                  // Kitabın yeni içeriklerini firebaseya yükleme.
                  await firestore
                      .collection('favorite_books')
                      .doc(bookId)
                      .update({
                        'Book Name': newName,
                        'Author': newAuthor,
                        'Description': newDescription,
                        'Year Of Publication': newYear,
                        'Image': newPhoto,
                      })
                      // Güncelleme işlemi başarılı olduğunda.
                      .then((value) => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content: Text('Kitap başarıyla güncellendi!'))))
                      // Güncelleme işlemi başarısız olduğunda.
                      .catchError((error) => ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                              content: Text(
                                  'Kitap güncellenirken bir hata oluştu: $error'))));

                  //verileri tekrardan firebasenin ilgili kısımından çeken ve books listesini tekrardan güncellemeye yarayan kısım.
                  final FirebaseFirestore firestoree =
                      FirebaseFirestore.instance;
                  final String userId = FirebaseAuth.instance.currentUser!.uid;
                  final QuerySnapshot snapshot = await firestoree
                      .collection('favorite_books')
                      .where('Person Who Added', isEqualTo: userId)
                      .get();
                  final List<QueryDocumentSnapshot> updateBooks = snapshot.docs;
                  setState(() {
                    widget.books = updateBooks;
                  });

                  // Açılan dialog widgetinden çıkış yapma.
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              ),
              // Güncelleme işlemini iptal etmek için oluşturulan kısım.
              TextButton(
                child: const Text('İptal'),
                onPressed: () {
                  // Eğer iptal işlemine basıldıysa dialog widgetini kapatan ve mevcut ekrana context ile dönmemizi sağlayan kısım.
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    var books = widget.books;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 50,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
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
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: const Text(
          'Kitap Listesi',
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
        child: ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              // Kitap verilerini alın
              final book = books[index].data() as Map<String, dynamic>;
              final bookId = books[index].id;
              // Kitap bilgilerini ve fotoğrafını gösteren widget döndürün
              if (widget.comingUserID == null) {
                return Slidable(
                    // Define the action pane for the end side (left to right)
                    endActionPane: ActionPane(
                      extentRatio: 0.7,
                      // Choose a motion for the pane
                      motion: const DrawerMotion(),
                      // Add the actions for the pane
                      children: [
                        // A SlidableAction that shows an edit icon
                        SlidableAction(
                          onPressed: (context) {
                            // Call the editItem function when pressed
                            _updateBook(bookId);
                          },
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          label: 'Düzenle',
                          borderRadius: BorderRadius.circular(40),
                        ),
                        SlidableAction(
                            onPressed: (context) {
                              // Call the editItem function when pressed
                              _deleteBook(bookId);
                            },
                            backgroundColor: Colors.red,
                            icon: Icons.edit,
                            label: 'Sil',
                            borderRadius: BorderRadius.circular(40)),
                      ],
                    ),
                    child: ShowBooks(
                      bookPics: book['Image'],
                      bookName: book['Book Name'],
                      bookAuthor: book['Author'],
                      bookYear: book['Year Of Publication'],
                      BookDescription: book['Description'],
                      bookAddTime: book['Upload Date'].toDate(),
                    ));
              } else {
                return ShowBooks(
                  bookPics: book['Image'],
                  bookName: book['Book Name'],
                  bookAuthor: book['Author'],
                  bookYear: book['Year Of Publication'],
                  BookDescription: book['Description'],
                  bookAddTime: book['Upload Date'].toDate(),
                );
              }
            }),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}
