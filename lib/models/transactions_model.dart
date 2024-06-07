import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class MyTransaction {
  const MyTransaction({
    this.userID,
    this.audioBookID,
    this.transactionID,
    this.transactionRef,
    this.stripeCustomerID,
    this.stripeChargeID,
    this.stripePaymentID,
    this.stripeRefundID,
    this.notes,
    this.paymentMethod,
    this.receiptID,
    this.type,
    this.amount,
    this.createdDate,
  });

  MyTransaction.fromJson(Map<String, Object?> json)
      : this(
          userID: json['userID']! as String,
          audioBookID: json['audioBookID']! as String,
          transactionID: json['transactionID']! as String,
          transactionRef: json['transactionRef']! as String,
          stripeCustomerID: json['stripeCustomerID']! as String,
          stripeChargeID: json['stripeChargeID']! as String,
          stripePaymentID: json['stripePaymentID']! as String,
          stripeRefundID: json['stripeRefundID']! as String,
          notes: json['notes']! as String,
          paymentMethod: json['paymentMethod']! as String,
          receiptID: json['receiptID']! as String,
          type: json['type']! as String,
          amount: json['amount']! as num,
          createdDate: json['createdDate']! as Timestamp,
        );

  final String? userID;
  final String? audioBookID;
  final String? transactionID;
  final String? transactionRef;
  final String? stripeCustomerID;
  final String? stripeChargeID;
  final String? stripePaymentID;
  final String? stripeRefundID;
  final String? notes;
  final String? paymentMethod;
  final String? receiptID;
  final String? type;
  final num? amount;
  final Timestamp? createdDate;

  Map<String, Object?> toJson() {
    return {
      'userID': userID,
      'audioBookID': audioBookID,
      'transactionID': transactionID,
      'transactionRef': transactionRef,
      'stripeCustomerID': stripeCustomerID,
      'stripeChargeID': stripeChargeID,
      'stripePaymentID': stripePaymentID,
      'stripeRefundID': stripeRefundID,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'receiptID': receiptID,
      'type': type,
      'amount': amount,
      'createdDate': createdDate,
    };
  }
}
