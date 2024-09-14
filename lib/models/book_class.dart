import 'package:flutter/material.dart';
import 'package:location/location.dart';

class _BookClassPage extends StatefulWidget {
  final String bookID;
  final String bookName;
  final String author;
  final Location location;
  final DateTime addedTime;
  final int bookYear;
  final String bookDescription;
  final String addedPerson;

  _BookClassPage({
    required this.bookID,
    required this.bookName,
    required this.author,
    required this.location,
    required this.addedTime,
    required this.bookYear,
    required this.bookDescription,
    required this.addedPerson,
    Key? key})
    :super(key: key);

  @override
  State<_BookClassPage> createState() => __BookClasStateState();
}

class __BookClasStateState extends State<_BookClassPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}