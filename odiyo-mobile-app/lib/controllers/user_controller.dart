import 'package:get/get.dart';
import 'package:odiyo/models/users_model.dart';

class UserController extends GetxController {
  Rx<User> currentUser = User().obs;
}
