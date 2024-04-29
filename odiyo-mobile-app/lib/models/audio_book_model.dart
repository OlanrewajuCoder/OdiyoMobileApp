import 'package:cloud_firestore/cloud_firestore.dart';

class AudioBook {
  final String? audioBookID;
  final String? title;
  final String? author;
  final String? description;
  final String? category;
  final num? price;
  final String? poster;
  num? rating;
  int? ratingsCount;
  final Timestamp? createdDate;
  final bool? isFeatured;
  final List? chapters;
  final List? chapterTitles;
  final List? countries;

  AudioBook({
    this.audioBookID,
    this.title,
    this.author,
    this.description,
    this.category,
    this.price,
    this.poster,
    this.rating,
    this.ratingsCount,
    this.createdDate,
    this.isFeatured,
    this.chapters,
    this.chapterTitles,
    this.countries,
  });

  factory AudioBook.empty() => AudioBook();

  AudioBook.fromJson(Map<String, Object?> json)
      : this(
          audioBookID: json['audioBookID']! as String,
          title: json['title']! as String,
          author: json['author']! as String,
          description: json['description']! as String,
          category: json['category']! as String,
          price: json['price']! as num,
          poster: json['poster']! as String,
          rating: json['rating']! as num,
          ratingsCount: json['ratingsCount']! as int,
          createdDate: json['createdDate']! as Timestamp,
          isFeatured: (json['isFeatured'] ?? false) as bool,
          chapters: (json['chapters'] ?? []) as List,
          chapterTitles: (json['chapterTitles'] ?? (json['chapters'] ?? []) as List) as List,
          countries: (json['countries'] ?? []) as List,
        );

  Map<String, Object?> toJson() {
    return {
      'audioBookID': audioBookID,
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'price': price,
      'poster': poster,
      'rating': rating,
      'ratingsCount': ratingsCount,
      'createdDate': createdDate,
      'isFeatured': isFeatured,
      'chapters': chapters,
      'chapterTitles': chapterTitles,
      'countries': countries,
    };
  }
}
