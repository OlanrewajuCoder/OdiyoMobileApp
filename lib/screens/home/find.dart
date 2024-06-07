import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/screens/audiobooks/books_list.dart';
import 'package:odiyo/screens/profile/favorites.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/empty_box.dart';
import 'package:odiyo/widgets/search_item.dart';

class AlgoliaApplication {
  static const Algolia algolia = Algolia.init(
    applicationId: 'W7NIQLUZ1M', //ApplicationID
    apiKey: 'f69201399ef033c441132bff4eb21a86', //search-only api key in flutter code
  );
}

class Find extends StatelessWidget {
  Find({Key? key}) : super(key: key);

  final firestoreService = Get.find<FirestoreService>();
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  final RxString _searchTerm = ''.obs;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("dev_odiyo").query(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: TextField(
              onChanged: (val) {
                _searchTerm.value = val;
              },
              style: const TextStyle(color: Colors.black, fontSize: 20),
              decoration: const InputDecoration(
                fillColor: Colors.white,
                border: InputBorder.none,
                hintText: 'Search ...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          Obx(() {
            return _searchTerm.value != ''
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        StreamBuilder<List<AlgoliaObjectSnapshot>>(
                          stream: Stream.fromFuture(_operation(_searchTerm.value)),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            } else {
                              List<AlgoliaObjectSnapshot> currSearchStuff = snapshot.data!;
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                default:
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return currSearchStuff.isNotEmpty
                                        ? CustomScrollView(
                                            shrinkWrap: true,
                                            slivers: <Widget>[
                                              SliverList(
                                                delegate: SliverChildBuilderDelegate(
                                                  (context, index) {
                                                    if (_searchTerm.value.isNotEmpty) {
                                                      return DisplaySearchResult(
                                                        title: currSearchStuff[index].data["title"],
                                                        audioBookID: currSearchStuff[index].data["audioBookID"],
                                                        poster: currSearchStuff[index].data["poster"],
                                                      );
                                                    } else {
                                                      return Container();
                                                    }
                                                  },
                                                  childCount: currSearchStuff.length,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const EmptyBox(text: 'Nothing to show. Try some other keyword');
                                  }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: TextButton(
                                  child: const Text('Latest', style: TextStyle(color: Colors.white70)),
                                  onPressed: () => Get.to(() => BookList(title: 'Latest', value: ListType.recent)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                child: TextButton(
                                  child: const Text('Top Rated', style: TextStyle(color: Colors.white70)),
                                  onPressed: () => Get.to(() => BookList(title: 'Top Rated', value: ListType.topRated)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: TextButton(
                                  child: const Text('Popular', style: TextStyle(color: Colors.white70)),
                                  onPressed: () => Get.to(() => BookList(title: 'Popular', value: ListType.popular)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                child: TextButton(
                                  child: const Text('Favorites', style: TextStyle(color: primaryColor)),
                                  onPressed: () => Get.to(() => const Favorites()),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const ListTile(
                        contentPadding: EdgeInsets.only(left: 30, top: 30),
                        title: Text('Categories', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(left: 15),
                        itemCount: categories.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () => Get.to(() => BookList(title: categories[index], value: ListType.category)),
                            title: Text(categories[index], style: const TextStyle(color: Colors.white)),
                            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                          );
                        },
                      ),
                    ],
                  );
          }),
        ],
      ),
    );
  }
}
