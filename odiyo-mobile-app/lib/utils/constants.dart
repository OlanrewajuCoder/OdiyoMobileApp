import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color primaryColor = Color(0xff2fbfc8);
const Color backgroundColor = Color(0xff2B323C);
const Color lightBackgroundColor = Color(0xff424547);
const Color secondaryColor = Color(0xff1F262E);
final Color redColor = Colors.red.shade600;

const LinearGradient linearGradient = LinearGradient(
  colors: [Colors.black, secondaryColor, Colors.black, secondaryColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const LinearGradient lightLinearGradient = LinearGradient(
  colors: [Colors.black, backgroundColor, secondaryColor, backgroundColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

showRedAlert(String text) {
  return Get.snackbar('Error', text, backgroundColor: redColor, colorText: Colors.white, margin: const EdgeInsets.all(15), animationDuration: const Duration(milliseconds: 500));
}

showGreenAlert(String text) {
  return Get.snackbar('Success', text, backgroundColor: primaryColor, colorText: Colors.white, margin: const EdgeInsets.all(15), animationDuration: const Duration(milliseconds: 500));
}

showYellowAlert(String text) {
  Get.snackbar('Please wait', text, backgroundColor: Colors.amber, colorText: Colors.black, margin: const EdgeInsets.all(15), animationDuration: const Duration(milliseconds: 500));
}

enum ListType { featured, category, recent, topRated, popular }

List categories = [
  'Action and adventure',
  'Alternate history',
  'Anthology',
  'Art/architecture',
  'Autobiography',
  'Biography',
  'Business/economics',
  'Chick lit',
  'Children',
  'Classic',
  'Comic book',
  'Coming-of-age',
  'Cookbook',
  'Crafts/hobbies',
  'Crime',
  'Diary',
  'Dictionary',
  'Drama',
  'Encyclopedia',
  'Fairytale',
  'Fantasy',
  'Graphic novel',
  'Guide',
  'Health/fitness',
  'Historical fiction',
  'History',
  'Home and garden',
  'Horror',
  'Humor',
  'Journal',
  'Math',
  'Memoir',
  'Mystery',
  'Paranormal romance',
  'Philosophy',
  'Picture book',
  'Poetry',
  'Political thriller',
  'Prayer',
  'Religion, spirituality, and new age',
  'Review',
  'Romance',
  'Satire',
  'Science',
  'Science fiction',
  'Self help',
  'Short story',
  'Sports and leisure',
  'Suspense',
  'Textbook',
  'Thriller',
  'Travel',
  'True crime',
  'Western',
  'Young adult',
];
