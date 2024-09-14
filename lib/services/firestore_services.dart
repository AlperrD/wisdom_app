import 'package:cloud_firestore/cloud_firestore.dart';

//
// internetten bulunan Firebase işlemleri için kullanılacak modeller. Örnek olarak inceleyebilirsin. (Alper).
//






/// Firestore ile bağlantı kuralım ve bir değişkene atayalım.
FirebaseFirestore firestore = FirebaseFirestore.instance;



Future<void> reads() async{
  /// READ 
  // Firestore'da her koleksiyon ve dokümanın kendine özgü bir referansı vardır ve bu referans üzerinden veriye erişiriz.
  CollectionReference users = firestore.collection("users"); // users koleksiyonunun referansı
  // Dokümanların koleksiyonları oluşturduğunu söylemiştik, koleksiyon altındaki dokümanlara da referans verebiliriz.
  DocumentReference bariskodas = firestore.collection("users").doc("bariskodas"); 

  /// Veri çekme metodları: bunun için iki tür metod kullanıyoruz
  // 1) .get() metodu: veriyi getirir ve bir listeye aktararak lokalleştiririz.
  FirebaseFirestore.instance.collection('users') // users koleksiyonuna git
    .get() // veriyi getir
    .then((QuerySnapshot querySnapshot) { // Firestoredan sana dönen veriyi değişkene al
        querySnapshot.docs.forEach((doc) {  // veriyi ayıkla ve ekrana yaz
            print(doc["first_name"]); 
        });
    });

  // QuerySnapshot: Koleksiyon sorgularından sonra Firestore tarafından bize döndürülür ve
  // içindeki verilerin anlık görüntüsünü bize verir.

// 2) .snapshot() metodu: Bu metod da bize bir QuerySnapshot döndürür fakat Stream tipindedir, 
// yani gerçek zamanlı olarak verileri devamlı bize akıtır, genelde StreamBuilder widgetı ile kullanırız.
Stream collectionStream = FirebaseFirestore.instance.collection('users').snapshots(); // veriyi anlık olarak al
Stream documentStream = FirebaseFirestore.instance.collection('users').doc('bariskodas').snapshots();
}

Future<void> creates() async{
/// CREATE
// Firestore'a iki tür metodla veri ekleyebilirsiniz.
// 1) .add() metodu: ekleyeceğimiz dokümanın ID'sini kendisi otomatik olarak atar.

    Future<void> addUser() { // kullanıcı ekleme fonksiyonumuz
      return firestore.collection('users')  // users koleksiyonuna git
          .add( // add metodunu tetikle doküman ID'sini otomatik ata ve mapteki verileri yaz
            {'full_name': "Barış Kodaş", 'Flutter Students Club': "company",'age': "21" } // key-value Map nesnesi
          )
          .then((value) => print("Kullanıcı eklendi"))
          .catchError((error) => print("Hata oluştu: $error"));
    }
// 2) .set() metodu: ekleyeceğimiz dokümanın ID'sini kendimiz manuel olarak atarız.

    Future<void> addUserSet() { // kullanıcı ekleme fonksiyonumuz
      return firestore.collection('users') // users koleksiyonuna git
          .doc("bariskodas")  // bariskodas dokümanını seç
          .set( // eğer bariskodas dokümanı yoksa oluştur ve mapteki verileri yaz
            {'full_name': "Barış Kodaş", "company":'Flutter Students Club', 'age': "21" } // key-value Map nesnesi
          )
          .then((value) => print("Kullanıcı eklendi"))
          .catchError((error) => print("Hata oluştu: $error"));
    }
}

Future<void> update() async{
/// UPDATE

Future<void> updateUser() {
  return firestore.collection("users") // users koleksiyonuna git
    .doc('bariskodas') // bariskodas kullanıcını seç
    .update({'company': 'FSC'}) // mapteki verileri güncelle
    .then((value) => print("Kullanıcı güncellendi"))
    .catchError((error) => print("Güncelleme sırasında hata oluştu: $error"));
}
}
Future<void> deletes() async{
/// DELETE

// Doküman silme
Future<void> deleteUser() {
  return firestore.collection("users")
    .doc('bariskodas')
    .delete() // dokümanı sil
    .then((value) => print("Kullanıcı silindi"))
    .catchError((error) => print("Silinirken hata oluştu: $error"));
} 
 
// Dokümanın içindeki bir alandaki veriyi silme
Future<void> deleteField() {
  return firestore.collection("users")
    .doc('bariskodas')
    .update({'age': FieldValue.delete()}) // Update metodunu kullanarak alandaki veriyi sildik, 'age' alanı kalmaya devam devam eder.
    .then((value) => print("Alandaki veri silindi"))
    .catchError((error) => print("Alandaki veri silinirken hata oluştu: $error"));
}
}

Future<void> queries() async{
/// Qerying - sorgulama
// Veritabanıyla kurduğumuz her temas birer sorgudur, 
// bu sorguların cevabını isteklerimize göre değiştirebiliriz.
 // Filtreleme - .where() metodu
 firestore.collection('users') // users koleksiyonuna git
  .where('age', // içindeki dokümanların 'age' alanını tara
  isGreaterThan: 20) // ve 20 den büyük olanları seç
  .get(); // getir

// Limitlendirme - .limit() metodu 
  firestore.collection('users') // users koleksiyonuna git
  .limit(2) // ilk 2 belgeyi seç
  .get(); // getir

// Limitlendirme - .limitToLast() metodu
  firestore.collection('users') // users koleksiyonuna git
  .orderBy('age') // 'age' alanındaki verilere göre sırala
  .limitToLast(2) // sondan başlayarak iki belgeyi
  .get(); // getir

// Ordering (Sıralama) Bu sorgu türü genelde sayısalve tarih-saat bilgisi tutan alanlar için kullanılır.
  firestore.collection('users') 
  .orderBy('age', // 'age' e göre sırala.
  descending: true) //  descending: azalan, ascending: artan anlamına gelir.
  .get();
}