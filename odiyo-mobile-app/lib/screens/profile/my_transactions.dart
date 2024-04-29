import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:odiyo/models/transactions_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/empty_box.dart';
import 'package:odiyo/widgets/loading.dart';
import 'package:odiyo/widgets/transaction_item.dart';

class Transactions extends StatelessWidget {
  Transactions({Key? key}) : super(key: key);

  final firestoreService = Get.find<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Transactions')),
        body: PaginateFirestore(
          physics: const BouncingScrollPhysics(),
          key: GlobalKey(),
          padding: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
          itemBuilderType: PaginateBuilderType.listView,
          itemBuilder: (context, List<DocumentSnapshot> documentSnapshot, i) => SizedBox(height: 200, child: TransactionItem(transaction: documentSnapshot[i].data()! as MyTransaction)),
          query: firestoreService.getMyTransactions(10),
          onEmpty: const EmptyBox(text: 'No transactions to show'),
          itemsPerPage: 10,
          bottomLoader: const LoadingData(),
          initialLoader: const LoadingData(),
        ),
      ),
    );
  }
}
