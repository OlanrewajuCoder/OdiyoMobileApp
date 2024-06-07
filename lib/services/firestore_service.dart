import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/models/favorites_model.dart';
import 'package:odiyo/models/review_model.dart';
import 'package:odiyo/models/transactions_model.dart';
import 'package:odiyo/models/users_model.dart';
import 'package:odiyo/services/location_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/utils/preferences.dart';

class FirestoreService {
  /* * * * * * * * * * * * * * * * DECLARATION SECTION * * * * * * * * * * * * * * * * */

  final userController = Get.find<UserController>();
  final ref = FirebaseFirestore.instance;
  final audioBookRef = FirebaseFirestore.instance.collection('audiobooks').withConverter<AudioBook>(fromFirestore: (snapshots, _) => AudioBook.fromJson(snapshots.data()!), toFirestore: (audiobook, _) => audiobook.toJson());
  final userRef = FirebaseFirestore.instance.collection('users').withConverter<User>(fromFirestore: (snapshots, _) => User.fromJson(snapshots.data()!), toFirestore: (user, _) => user.toJson());
  final favoritesRef = FirebaseFirestore.instance.collection('favorites').withConverter<Favorite>(fromFirestore: (snapshots, _) => Favorite.fromJson(snapshots.data()!), toFirestore: (favorite, _) => favorite.toJson());
  final reviewRef = FirebaseFirestore.instance.collection('reviews').withConverter<Review>(fromFirestore: (snapshots, _) => Review.fromJson(snapshots.data()!), toFirestore: (review, _) => review.toJson());
  final transactionRef = FirebaseFirestore.instance.collection('transactions').withConverter<MyTransaction>(fromFirestore: (snapshots, _) => MyTransaction.fromJson(snapshots.data()!), toFirestore: (transaction, _) => transaction.toJson());

  /* * * * * * * * * * * * * * * * AUDIOBOOK SECTION * * * * * * * * * * * * * * * * */

  Future<DocumentSnapshot<AudioBook>> getAudioBookByID(String audioBookID) => audioBookRef.doc(audioBookID).get();

  Future<QuerySnapshot<AudioBook>> getAudioBooks(int limit) => audioBookRef.orderBy('createdDate', descending: true).limit(limit).get();

  Stream<QuerySnapshot<AudioBook>> getAudioBooksStream(int limit, String orderBy) => audioBookRef.where('countries', arrayContains: LocationService.country).orderBy(orderBy, descending: true).limit(limit).snapshots();

  Query getAudioBooksWhere(String name, String value, int limit) => audioBookRef.where(name, isEqualTo: value).where('countries', arrayContains: LocationService.country).limit(limit);

  Stream<QuerySnapshot<AudioBook>> getAudioBooksWhereStream(String name, value, int limit, String orderBy) => audioBookRef.where(name, isEqualTo: value).where('countries', arrayContains: LocationService.country).orderBy(orderBy, descending: true).limit(limit).snapshots();

  Future editAudioBookRatingsCount(AudioBook audioBook) async => await audioBookRef.doc(audioBook.audioBookID).update(audioBook.toJson());

  Future addBook(AudioBook audioBook) async => await audioBookRef.doc(audioBook.audioBookID).set(audioBook);

  Future editBook(AudioBook audioBook) async => await audioBookRef.doc(audioBook.audioBookID).update(audioBook.toJson());

  /* * * * * * * * * * * * * * * * USER SECTION * * * * * * * * * * * * * * * * */

  Future addUser(User user) async => await userRef.doc(user.userID).set(user).catchError((e) => showRedAlert(e.toString()));

  Future editUser(User user) async => await userRef.doc(userController.currentUser.value.userID).update(user.toJson()).then((value) async => userController.currentUser.value = (await getUser(await Preferences.getUser())).data()!).catchError((e) => showRedAlert(e.toString()));

  Future editOtherUser(User user) async => await userRef.doc(user.userID).update(user.toJson());

  Future<DocumentSnapshot<User>> getUser(String userID) async => await userRef.doc(userID).get();

  Stream<DocumentSnapshot<User>> getUserStream(String userID) => userRef.doc(userID).snapshots();

  Future<bool> checkIfUserExists(String email) async => (await userRef.where('email', isEqualTo: email).get()).docs.isNotEmpty;

  Future<DocumentSnapshot<User>> getUserFromEmail(String email) async => (await userRef.where('email', isEqualTo: email).get()).docs[0];

  /* * * * * * * * * * * * * * * * FAVORITES SECTION * * * * * * * * * * * * * * * * */

  Stream<QuerySnapshot<Favorite>> getMyFavorites(int limit) => favoritesRef.where('userID', isEqualTo: userController.currentUser.value.userID).orderBy('createdDate', descending: true).limit(limit).snapshots();

  Future addToFavorites(Favorite favorite) async => await favoritesRef.doc('${userController.currentUser.value.userID}|${favorite.audioBookID}').set(favorite);

  Future removeFromFavorites(String audioBookID) async => await favoritesRef.doc('${userController.currentUser.value.userID}|$audioBookID').delete();

  Stream<DocumentSnapshot<Favorite>> checkIfFavorite(String audioBookID) => favoritesRef.doc('${userController.currentUser.value.userID}|$audioBookID').snapshots();

  /* * * * * * * * * * * * * * * * REVIEWS SECTION * * * * * * * * * * * * * * * * */

  Future addReview(Review review, AudioBook audioBook) async => await reviewRef.doc(review.reviewID).set(review);

  Stream<QuerySnapshot<Review>> getAudioBookReviews(String audioBookID, int limit) => reviewRef.where('audioBookID', isEqualTo: audioBookID).orderBy('createdDate', descending: true).limit(limit).snapshots();

  Query<Review> getAudioBookReviewsQuery(String audioBookID, int limit) => reviewRef.where('audioBookID', isEqualTo: audioBookID).orderBy('createdDate', descending: true).limit(limit);

  /* * * * * * * * * * * * * * * * TRANSACTIONS SECTION * * * * * * * * * * * * * * * * */

  Future addTransaction(MyTransaction transaction) async => await transactionRef.doc(transaction.transactionID).set(transaction);

  Future<bool> checkIfPurchased(String audioBookID) async => (await transactionRef.where('audioBookID', isEqualTo: audioBookID).where('userID', isEqualTo: userController.currentUser.value.userID).get()).docs.isNotEmpty;

  Query<MyTransaction> getMyTransactions(int limit) => transactionRef.where('userID', isEqualTo: userController.currentUser.value.userID).orderBy('createdDate', descending: true).limit(limit);

  Future<DocumentSnapshot> getConstants() async => await ref.collection('constants').doc('policy').get();

// addToAlgolia(AudioBook audioBook) async {
//   const Algolia algolia = Algolia.init(
//     applicationId: 'W7NIQLUZ1M', //ApplicationID
//     apiKey: '973577d5454c47673764e04c069b011f', //search-only api key in flutter code
//   );
//
//   String key = '973577d5454c47673764e04c069b011f';
//   final Algolia _algoliaApp = algolia;
//   await _algoliaApp.instance.index('dev_odiyo').addObject({
//     'audioBookID': audioBook.audioBookID,
//     'title': audioBook.title,
//     'description': audioBook.description,
//     'category': audioBook.category,
//     'url': audioBook.url,
//     'price': audioBook.price,
//     'poster': audioBook.poster,
//     'runtime': audioBook.runtime,
//     'rating': audioBook.rating,
//     'ratingsCount': audioBook.ratingsCount,
//   });
// }
}
