import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? userID;
  final String? reviewID;
  final String? audioBookID;
  final String? comment;
  final bool? flagged;
  final num? rating;
  final Timestamp? createdDate;

  Review({
    this.userID,
    this.reviewID,
    this.audioBookID,
    this.comment,
    this.flagged,
    this.rating,
    this.createdDate,
  });

  Review.fromJson(Map<String, Object?> json)
      : this(
          userID: json['userID']! as String,
          reviewID: json['reviewID']! as String,
          audioBookID: json['audioBookID']! as String,
          comment: json['comment']! as String,
          flagged: json['flagged']! as bool,
          rating: json['rating']! as num,
          createdDate: json['createdDate']! as Timestamp,
        );

  Map<String, Object?> toJson() {
    return {
      'userID': userID,
      'reviewID': reviewID,
      'audioBookID': audioBookID,
      'comment': comment,
      'flagged': flagged,
      'rating': rating,
      'createdDate': createdDate,
    };
  }
}
