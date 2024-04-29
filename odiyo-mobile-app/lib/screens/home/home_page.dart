import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/screens/audiobooks/books_list.dart';
import 'package:odiyo/screens/auth/login.dart';
import 'package:odiyo/screens/home/find.dart';
import 'package:odiyo/screens/home/home.dart';
import 'package:odiyo/screens/home/library.dart';
import 'package:odiyo/screens/profile/favorites.dart';
import 'package:odiyo/screens/profile/my_transactions.dart';
import 'package:odiyo/screens/profile/profile.dart';
import 'package:odiyo/services/authentication_service.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/audio_book_item.dart';
import 'package:odiyo/widgets/cached_image.dart';
import 'package:odiyo/widgets/custom_list_tile.dart';
import 'package:odiyo/widgets/loading.dart';
import 'package:odiyo/widgets/mini_player.dart';
//import 'package:share/share.dart';

class HomeController extends GetxController {
  var tabIndex = 0;

  changeTabIndex(index) {
    tabIndex = index;
    update();
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final controller = Get.put(HomeController());
  final PageController pageController = PageController(initialPage: 1, viewportFraction: 0.8);
  final _key = GlobalKey();
  final userController = Get.find<UserController>();
  final utilService = Get.find<UtilService>();
  final firestoreService = Get.find<FirestoreService>();

  showList(String title, ListType value) {
    Stream<QuerySnapshot<AudioBook>> stream = firestoreService.getAudioBooksStream(10, 'createdDate');
    switch (value) {
      case ListType.recent:
        stream = firestoreService.getAudioBooksStream(10, 'createdDate');
        break;
      case ListType.featured:
        stream = firestoreService.getAudioBooksWhereStream('isFeatured', true, 10, 'createdDate');
        break;
      case ListType.category:
        stream = firestoreService.getAudioBooksWhereStream('category', title, 10, 'createdDate');
        break;
      case ListType.topRated:
        stream = firestoreService.getAudioBooksStream(10, 'rating');
        break;
      case ListType.popular:
        stream = firestoreService.getAudioBooksStream(10, 'ratingsCount');
        break;
      default:
        stream = firestoreService.getAudioBooksStream(10, 'createdDate');
        break;
    }

    return StreamBuilder<QuerySnapshot<AudioBook>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (!snapshot.hasData) {
          return const LoadingData();
        }

        final data = snapshot.requireData;

        if (value == ListType.featured) {
          return CarouselSlider(
            options: CarouselOptions(
              height: Get.width / .95,
              viewportFraction: 0.7,
              initialPage: 1,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              //aspectRatio: 1.5,
            ),
            items: data.docs.map((i) => AudioBookItem(audioBook: i.data())).toList(),
          );
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(title, textScaleFactor: 1.2, style: const TextStyle(color: Colors.white)),
                    IconButton(onPressed: () => Get.to(() => BookList(title: title, value: value)), icon: const Icon(Icons.arrow_forward)),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: Get.width / 2,
                      child: AudioBookItem(audioBook: data.docs[index].data()),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (HomeController controller) {
      return Container(
        decoration: const BoxDecoration(gradient: lightLinearGradient),
        child: Scaffold(
          key: _key,
          appBar: AppBar(
            title: const Image(image: AssetImage('assets/images/only_logo.png'), height: 45),
            leading: userController.currentUser.value.userID == null
                ? null
                : Builder(builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  }),
            // actions: <Widget>[
            // if (userController.currentUser.value.userID != null)
            //   IconButton(
            //     icon: const Icon(Icons.notifications_none_outlined),
            //     onPressed: () => Get.to(() => const Notifications(), duration: const Duration(seconds: 0)),
            //   )
            // ],
          ),
          drawer: userController.currentUser.value.userID == null
              ? null
              : Drawer(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    width: Get.width * 0.7,
                    height: double.infinity,
                    margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).viewPadding.top, 0, Get.bottomBarHeight),
                    decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Obx(
                          () => Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                              color: Colors.black38,
                            ),
                            child: Column(
                              children: [
                                Row(children: [IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back))]),
                                const SizedBox(height: 10),
                                CircleAvatar(radius: 55, backgroundColor: primaryColor, child: CachedImage(url: userController.currentUser.value.photoURL, height: 100, circular: true)),
                                const SizedBox(height: 15),
                                Text(userController.currentUser.value.name!, textScaleFactor: 1.25, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                TextButton(onPressed: () {}, child: const Text('Freemium Member')),
                                //TextButton(onPressed: () => Get.to(() => const Membership()), child: const Text('View Membership', style: TextStyle(decoration: TextDecoration.underline, color: primaryColor))),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                CustomListTile(
                                  leading: const Icon(Icons.new_releases_outlined, color: Colors.white70),
                                  title: const Text('New Releases', style: TextStyle(color: Colors.white70)),
                                  onTap: () => Get.to(() => BookList(title: 'New Releases', value: ListType.recent)),
                                ),
                                CustomListTile(
                                  leading: const Icon(Icons.star_border_outlined, color: Colors.white70),
                                  title: const Text('Top Rated', style: TextStyle(color: Colors.white70)),
                                  onTap: () => Get.to(() => BookList(title: 'Top Rated', value: ListType.topRated)),
                                ),
                                CustomListTile(
                                  leading: const Icon(Icons.trending_up, color: Colors.white70),
                                  title: const Text('Most Popular', style: TextStyle(color: Colors.white70)),
                                  onTap: () => Get.to(() => BookList(title: 'Most Popular', value: ListType.popular)),
                                ),
                                const Divider(),
                                CustomListTile(
                                  leading: const Icon(FontAwesomeIcons.heart, color: Colors.white70),
                                  title: const Text('Favorites', style: TextStyle(color: Colors.white70)),
                                  onTap: () => Get.to(() => const Favorites()),
                                ),
                                CustomListTile(
                                  leading: const Icon(Icons.list_alt_outlined, color: Colors.white70),
                                  title: const Text('Transactions', style: TextStyle(color: Colors.white70)),
                                  onTap: () => Get.to(() => Transactions()),
                                ),
                                CustomListTile(
                                  leading: const Icon(Icons.logout, color: primaryColor),
                                  title: const Text('Sign Out', style: TextStyle(color: primaryColor)),
                                  onTap: () {
                                    Get.back();
                                    Get.defaultDialog(
                                      backgroundColor: lightBackgroundColor,
                                      titleStyle: const TextStyle(color: Colors.white),
                                      titlePadding: const EdgeInsets.only(top: 10),
                                      contentPadding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
                                      title: 'Logout',
                                      content: Column(
                                        children: [
                                          const Text('Are you sure you want to logout?'),
                                          const SizedBox(height: 25),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(onTap: () => Get.back(), child: const CircleAvatar(backgroundColor: backgroundColor, radius: 35, child: Icon(Icons.close, color: Colors.white))),
                                              InkWell(onTap: () async => await AuthService().signOut(), child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.check, color: Colors.white))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 40),
                                CustomListTile(
                                  leading: const Icon(Icons.share, color: Colors.white70),
                                  title: const Text('Tell A Friend', style: TextStyle(color: Colors.white70)),
                                  onTap: (){},// => Share.share('Get Odiyo from Play Store and App Store and enjoy an exciting collection of thousands of audio books. Download now'),
                                ),
                                const CustomListTile(
                                  leading: Icon(Icons.star, color: Colors.white70),
                                  title: Text('Rate Odiyo', style: TextStyle(color: Colors.white70)),
                                  //onTap: () async => await StoreLauncher.openWithStore('com.odiyo.app'),
                                ),
                                FutureBuilder<DocumentSnapshot>(
                                  future: firestoreService.getConstants(),
                                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      String privacy = snapshot.data!['policy'];
                                      String tnc = snapshot.data!['tnc'];

                                      return Column(
                                        children: [
                                          CustomListTile(
                                            leading: const Icon(Icons.list, color: Colors.white70),
                                            title: const Text('Terms of use', style: TextStyle(color: Colors.white70)),
                                            onTap: () => utilService.openLink(tnc),
                                          ),
                                          CustomListTile(
                                            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white70),
                                            title: const Text('Privacy Policy', style: TextStyle(color: Colors.white70)),
                                            onTap: () => utilService.openLink(privacy),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: secondaryColor,
            items: const [
              BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home_outlined, size: 20)),
              BottomNavigationBarItem(label: 'Library', icon: Icon(Icons.my_library_music_outlined, size: 20)),
              BottomNavigationBarItem(label: 'Find', icon: Icon(Icons.search, size: 20)),
              BottomNavigationBarItem(label: 'Profile', icon: Icon(Icons.person_outline, size: 20)),
            ],
            currentIndex: controller.tabIndex,
            onTap: (demo) {
              if (FirebaseAuth.instance.currentUser == null) {
                Get.offAll(() => const Login());
              } else {
                controller.changeTabIndex(demo);
              }
            },
          ),
          body: Stack(
            children: [
              IndexedStack(
                index: controller.tabIndex,
                children: [
                  Home(),
                  Library(),
                  Find(),
                  Profile(),
                ],
              ),
              const MiniPlayer(),
            ],
          ),
        ),
      );
    });
  }
}
