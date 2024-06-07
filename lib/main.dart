import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/screens/auth/splash_screen.dart';
import 'package:odiyo/services/authentication_service.dart';
import 'package:odiyo/services/buy_service.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/location_service.dart';
import 'package:odiyo/services/player_service.dart';
import 'package:odiyo/services/storage_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  AssetsAudioPlayer.setupNotificationsOpenAction((notification) {
    //custom action
    return false; //true : handled, does not notify others listeners
    //false : enable others listeners to handle it
  });

  AssetsAudioPlayer.addNotificationOpenAction((notification) {
    //custom action
    return false; //true : handled, does not notify others listeners
    //false : enable others listeners to handle it
  });

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(const MyApp());

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final double textSize = 17;
  final double buttonTextSize = 17;

  RxBool authenticated = false.obs;
  RxBool isLoading = true.obs;

  @override
  void initState() {
    addServices();
    super.initState();

    // FirebaseMessaging.instance.getInitialMessage();
    //
    // //foreground
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   //RemoteNotification? notification = message.notification;
    //   //AndroidNotification android = message.notification?.android;
    //   //   AppleNotification apple = message.notification?.apple;
    //   //if (notification != null)
    //   //showNotification(notification);
    // });
    //
    // //tap on notification and app minimized
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   // print('A new onMessageOpenedApp event was published!');
    //   // if (message.data['type'] == 'message') Get.to(() => Conversations());
    //   // if (message.data['type'] == 'vesselBookingRequest') Get.to(() => Notifications());
    //   // if (message.data['type'] == 'vesselBookingResponse') Get.to(() => Notifications());
    // });
  }

  @override
  Widget build(BuildContext context) {
    LocationService.country = 'Jamaica';
    return GetMaterialApp(
      title: 'Odiyo',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        primaryColor: primaryColor,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        checkboxTheme: CheckboxThemeData(checkColor: MaterialStateProperty.all(Colors.black), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), fillColor: MaterialStateProperty.all(primaryColor)),
        dialogTheme: DialogTheme(titleTextStyle: darkTextStyle(buttonTextSize * 1.25), contentTextStyle: darkTextStyle(textSize)),
        textTheme: TextTheme(headline6: darkTextStyle(textSize), bodyText2: darkTextStyle(textSize)),
        appBarTheme: AppBarTheme(centerTitle: true, color: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white), titleTextStyle: lightTextStyle(textSize * 1.25), systemOverlayStyle: SystemUiOverlayStyle.light),
        tabBarTheme: TabBarTheme(labelColor: primaryColor, indicatorSize: TabBarIndicatorSize.label, unselectedLabelColor: Colors.grey, labelStyle: darkTextStyle(textSize)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: primaryColor, type: BottomNavigationBarType.fixed, selectedItemColor: Colors.white, unselectedItemColor: Colors.white38),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(textStyle: MaterialStateProperty.all(TextStyle(fontSize: buttonTextSize)), shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))), foregroundColor: MaterialStateProperty.all(Colors.grey), minimumSize: MaterialStateProperty.all(const Size(45, 45)))),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(primaryColor), textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white, fontSize: buttonTextSize, fontWeight: FontWeight.bold, letterSpacing: 1.5)), shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))), minimumSize: MaterialStateProperty.all(const Size(double.infinity, 45)))),
        inputDecorationTheme: InputDecorationTheme(border: inputBorder(lightBackgroundColor), focusedBorder: inputBorder(lightBackgroundColor), enabledBorder: inputBorder(lightBackgroundColor), errorBorder: inputBorder(lightBackgroundColor), disabledBorder: inputBorder(lightBackgroundColor), hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: secondaryColor, contentPadding: const EdgeInsets.only(left: 20)),
        cardTheme: CardTheme(shadowColor: Colors.black87, margin: const EdgeInsets.all(5), elevation: 10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      //flutter pub run flutter_launcher_icons:main
    );
  }
}

inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(width: 1, color: color),
  );
}

darkTextStyle(double textSize) {
  return TextStyle(
    color: Colors.grey,
    //fontFamily: 'Font2',
    fontSize: textSize,
  );
}

lightTextStyle(double textSize) {
  return TextStyle(
    color: Colors.white,
    //fontFamily: 'Font2',
    fontSize: textSize,
  );
}

addServices() {
  Get.put(UtilService());
  Get.put(UserController());
  Get.put(FirestoreService());
  Get.put(StorageService());
  Get.put(AuthService());
//  Get.put(NotificationService());
  Get.put(BuyService());
  Get.put(PlayerService());
}
