import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pau_ybs_kitap_paylasim_tez/ui/widgets/review_card.dart';

class UserReviewService extends StatefulWidget {
  final String userNameSurname;
  final String userNickname;
  final String userProfileImagePath;
  final String? comingUserID;
  const UserReviewService({
    super.key,
    required this.userNameSurname,
    required this.userNickname,
    required this.userProfileImagePath,
    this.comingUserID,
  });

  @override
  State<UserReviewService> createState() => _UserReviewServiceState();
}

class _UserReviewServiceState extends State<UserReviewService> {
  Future<List<Map<String, dynamic>>> getReviews() async {
    //Review verilerinin oluşturma tarihine göre yeniden eskiye şeklinde snapshotlarını alır
    
    if (widget.comingUserID == null) {
      var reviewSnapshot = await FirebaseFirestore.instance
          .collection(
              '/userReviews/${FirebaseAuth.instance.currentUser!.uid}/reviews')
          .orderBy('timestamp', descending: true)
          .get();
      return reviewSnapshot.docs.map((review) => review.data()).toList();
    } else {
      var reviewSnapshot = await FirebaseFirestore.instance
          .collection('/userReviews/${widget.comingUserID}/reviews')
          .orderBy('timestamp', descending: true)
          .get();
      return reviewSnapshot.docs.map((review) => review.data()).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getReviews(),
      builder:
          (context, AsyncSnapshot<List<Map<String, dynamic>>> reviewSnapshot) {
        if (reviewSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (reviewSnapshot.hasError) {
          return Center(
            child: Text('Veriler alınamıyor: ${reviewSnapshot.error}'),
          );
        } else if (reviewSnapshot.data!.isEmpty) {
          return Center(child: Image.asset('assets/images/emptyReviews.png'));
        } else {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: reviewSnapshot.data!.length,
            itemBuilder: (context, index) {
              var review = reviewSnapshot.data![index];
              String reviewText = review['user_review'];
              Timestamp timestamp = review['timestamp'];
              DateTime datetime = timestamp.toDate();
              String formattedDate =
                  DateFormat('dd.MM.yyyy HH:mm').format(datetime);
              String reviewImagePath = review['user_review_photo'];

              return ReviewCard(
                userNameSurname: widget.userNameSurname,
                userNickname: widget.userNickname,
                review: reviewText,
                reviewImagePath: reviewImagePath,
                userProfileImagePath: widget.userProfileImagePath,
                timestamp: formattedDate,
              );
            },
          );
        }
      },
    );
  }
}
