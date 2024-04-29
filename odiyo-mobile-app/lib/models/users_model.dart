import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    this.userID,
    this.name,
    this.email,
    this.photoURL,
    this.membershipStatus,
    this.membershipExpiryDate,
    this.stripeCustomerID,
    this.stripeCustomerEphemeralKey,
    this.paymentID,
    this.token,
    this.unreadNotifications,
    this.preferences,
    this.createdDate,
  });

  User.fromJson(Map<String, Object?> json)
      : this(
          userID: json['userID']! as String,
          name: json['name']! as String,
          email: json['email']! as String,
          photoURL: ((json['photoURL'] ?? '') as String).isEmpty
              ? 'profile'
              : json['photoURL'].toString(),
          membershipStatus: (json['membershipStatus'] ?? 'free') as String,
          membershipExpiryDate:
              (json['membershipExpiryDate'] ?? Timestamp.now()) as Timestamp,
          stripeCustomerID: (json['stripeCustomerID'] ?? '') as String,
          stripeCustomerEphemeralKey:
              (json['stripeCustomerEphemeralKey'] ?? '') as String,
          paymentID: (json['paymentID'] ?? '') as String,
          token: json['token']! as String,
          unreadNotifications: (json['unreadNotifications'] ?? false) as bool,
          preferences: (json['preferences'] ?? []) as List,
          createdDate: (json['createdDate'] ?? Timestamp.now()) as Timestamp,
        );

  final String? userID;
  String? name;
  final String? email;
  String? photoURL;
  String? membershipStatus;
  Timestamp? membershipExpiryDate;
  String? stripeCustomerID;
  String? stripeCustomerEphemeralKey;
  String? paymentID;
  String? token;
  bool? unreadNotifications;
  List? preferences;
  Timestamp? createdDate;

  Map<String, Object?> toJson() {
    return {
      'userID': userID,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'membershipStatus': membershipStatus,
      'membershipExpiryDate': membershipExpiryDate,
      'stripeCustomerID': stripeCustomerID,
      'stripeCustomerEphemeralKey': stripeCustomerEphemeralKey,
      'paymentID': paymentID,
      'token': token,
      'unreadNotifications': unreadNotifications,
      'preferences': preferences,
      'createdDate': createdDate,
    };
  }
}
