import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/models/transactions_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/cached_image.dart';

class TransactionItem extends StatelessWidget {
  final MyTransaction? transaction;

  TransactionItem({Key? key, this.transaction}) : super(key: key);

  final firestoreService = Get.find<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<AudioBook>>(
        future: firestoreService.getAudioBookByID(transaction!.audioBookID!),
        builder: (context, AsyncSnapshot<DocumentSnapshot<AudioBook>> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            AudioBook audioBook = snapshot.requireData.data()!;
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(width: 120, child: CachedImage(url: audioBook.poster!, height: 200)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(audioBook.title!, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 5),
                        Text('Transaction ID: ${transaction!.transactionRef!}'),
                        const SizedBox(height: 5),
                        Text('Price: \$${transaction!.amount!}', style: const TextStyle(color: primaryColor)),
                        const SizedBox(height: 5),
                        Text(DateFormat('dd MMM yyyy, hh:mm aa').format(transaction!.createdDate!.toDate())),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
