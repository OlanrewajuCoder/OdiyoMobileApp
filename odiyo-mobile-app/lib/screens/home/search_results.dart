import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/empty_box.dart';
import 'package:odiyo/widgets/search_item.dart';

class AlgoliaApplication {
  static const Algolia algolia = Algolia.init(
    applicationId: 'W7NIQLUZ1M',
    apiKey: 'f69201399ef033c441132bff4eb21a86',
  );
}

class SearchResults extends StatelessWidget {
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  final RxString _searchTerm = ''.obs;

  SearchResults({Key? key}) : super(key: key);

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("dev_odiyo").query(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: lightLinearGradient),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
              autofocus: true,
              onChanged: (val) {
                _searchTerm.value = val;
              },
              style: const TextStyle(color: Colors.white, fontSize: 20),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search ...', hintStyle: TextStyle(color: Colors.grey), prefixIcon: Icon(Icons.search, color: Colors.grey))),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(),
            )
          ],
        ),
        body: Obx(() {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
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
          );
        }),
      ),
    );
  }
}
