import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme/app_colors.dart';
import 'full_screen_book_detail.dart';

class ShowBooks extends StatelessWidget {
  final String bookPics;
  final String bookName;
  final String bookAuthor;
  final String bookYear;
  final String BookDescription;
  final DateTime bookAddTime;

  const ShowBooks({
    Key? key,
    required this.bookPics,
    required this.bookName,
    required this.bookAuthor,
    required this.bookYear,
    required this.BookDescription,
    required this.bookAddTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenPage(
              bookAuthor: bookAuthor,
              bookName: bookName,
              bookYear: bookYear,
              BookDescription: BookDescription,
              bookAddTime: bookAddTime,
              child: Hero(
                tag: 'picsHero',
                child: CachedNetworkImage(
                  imageUrl: bookPics,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.imagePickerUsageAppBarColor,
            ),
            width: screenWidth,
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.imagePickerUsageAppBarColor,
                    ),
                    height: 150,
                    width: 150,
                    child: CachedNetworkImage(
                      imageUrl: bookPics,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                      placeholder: (context, url) => CircularProgressIndicator(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          bookName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.imagePickerUsageTextFieldColor,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          bookAuthor,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.imagePickerUsageTextFieldColor,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        bookYear,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.imagePickerUsageTextFieldColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}