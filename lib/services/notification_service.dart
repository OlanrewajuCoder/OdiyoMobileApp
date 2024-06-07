// // ignore_for_file: depend_on_referenced_packages
//
// import 'dart:convert';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:odiyo/controllers/user_controller.dart';
// import 'package:odiyo/models/users_model.dart';
// import 'package:odiyo/services/firestore_service.dart';
// import 'package:uuid/uuid.dart';
//
// class NotificationService {
//   final String serverToken = '';
//   final userController = Get.find<UserController>();
//   final userService = Get.find<FirestoreService>();
//   final ref = FirebaseFirestore.instance;
//
//   getNotifications(int limit, bool archived) {
//     return ref.collection("notifications").where('receiverUserID', isEqualTo: userController.currentUser.value.userID).where('archived', isEqualTo: archived).orderBy('createdDate', descending: true).limit(limit);
//   }
//
//   sendNotification({Map<String, dynamic>? parameters, String? receiverUserID, String? body, String? type}) async {
//     //GET RECEIVER USER FOR TOKEN
//     DocumentSnapshot doc = await userService.getUser(receiverUserID!);
//     User receiverUser = User.fromJson(doc as Map<String, dynamic>);
//
//     //ADD MANDATORY PARAMETERS FOR NOTIFICATION
//     parameters!['createdDate'] = Timestamp.now();
//     parameters['receiverUserID'] = receiverUserID;
//     parameters['notificationID'] = const Uuid().v1();
//     parameters['senderUserID'] = userController.currentUser.value.userID;
//     parameters['type'] = type;
//     parameters['archived'] = false;
//
//     await ref.collection('notifications').doc(parameters['notificationID']).set(parameters);
//     receiverUser.unreadNotifications = true;
//     await userService.editOtherUser(receiverUser);
//
//     //SEND NOTIFICATIONS
//     return await http.post(
//       Uri.parse('https://fcm.googleapis.com/fcm/send'),
//       headers: <String, String>{'Content-Type': 'application/json', 'Authorization': 'key=$serverToken'},
//       body: jsonEncode(
//         <String, dynamic>{
//           'notification': <String, dynamic>{'title': body, 'body': 'From : ${userController.currentUser.value.name!}'},
//           'priority': 'high',
//           'data': <String, dynamic>{
//             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//             'sound': 'default',
//             'id': '1',
//             'status': 'done',
//             'type': type,
//             'title': body,
//             'body': 'From : ${userController.currentUser.value.name!}',
//           },
//           'to': receiverUser.token,
//         },
//       ),
//     );
//   }
// }
