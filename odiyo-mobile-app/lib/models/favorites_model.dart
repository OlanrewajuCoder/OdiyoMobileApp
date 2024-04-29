import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class Favorite {
  const Favorite({
    this.userID,
    this.audioBookID,
    this.createdDate,
  });

  final String? userID;
  final String? audioBookID;
  final Timestamp? createdDate;

  Favorite.fromJson(Map<String, Object?> json)
      : this(
          userID: json['userID']! as String,
          audioBookID: json['audioBookID']! as String,
          createdDate: json['createdDate']! as Timestamp,
        );

  Map<String, Object?> toJson() {
    return {
      'userID': userID,
      'audioBookID': audioBookID,
      'createdDate': createdDate,
    };
  }
}
