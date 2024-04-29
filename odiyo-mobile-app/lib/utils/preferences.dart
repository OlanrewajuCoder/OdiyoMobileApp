import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userID') ?? '';
  }

  static setUser(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userID', value);
  }

  static getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('myRole') ?? 'User';
  }

  static setUserRole(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('myRole', value);
  }

  static getOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('OnboardingStatus') ?? false;
  }

  static setOnboardingStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('OnboardingStatus', value);
  }

  static getSignOutStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('signOutStatus') ?? false;
  }

  static setSignOutStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('signOutStatus', value);
  }
}
