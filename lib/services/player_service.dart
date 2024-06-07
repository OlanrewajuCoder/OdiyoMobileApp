import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:path_provider/path_provider.dart';

final audioPlayer = AssetsAudioPlayer.newPlayer();
Rx<AudioBook> currentAudioBook = AudioBook().obs;
RxInt index = 0.obs;

class PlayerService {
  initAudioBook() async {
    audioPlayer.onErrorDo = (error) {
      error.player.stop();
    };

    await audioPlayer.open(
      Playlist(
        audios: currentAudioBook.value.chapters
            ?.map((e) => Audio.network(
                  e,
                  metas: Metas(
                    id: currentAudioBook.value.audioBookID,
                    title: currentAudioBook.value.title,
                    artist: currentAudioBook.value.author,
                    image: MetasImage.network(
                      currentAudioBook.value.poster!,
                    ),
                    extra: {
                      'url': e,
                    },
                  ),
                ))
            .toList(),
      ),
      autoStart: false,
      loopMode: LoopMode.playlist,
      showNotification: true,
      playInBackground: PlayInBackground.enabled,
      notificationSettings: NotificationSettings(
        nextEnabled: currentAudioBook.value.chapters!.length > 1,
        prevEnabled: currentAudioBook.value.chapters!.length > 1,
        stopEnabled: true,
        playPauseEnabled: true,
        seekBarEnabled: true,
        customNextAction: (_) => next(),
        customPrevAction: (_) => previous(),
      ),
    );
    await audioPlayer.playlistPlayAtIndex(index.value);
  }

  playOrPause() async {
    await audioPlayer.playOrPause();
  }

  stop() async {
    await audioPlayer.stop();
  }

  next() async {
    await audioPlayer.next(stopIfLast: true);
    if (index < currentAudioBook.value.chapters!.length) {
      index++;
    }
  }

  previous() async {
    await audioPlayer.previous();
    if (index > 0) {
      index--;
    }
  }

  setAudioBookProgress(num seconds) async {
    final directory = await getApplicationDocumentsDirectory();
    final userController = Get.find<UserController>();
    final BoxCollection collection = await BoxCollection.open(
      'OdiyoDB',
      {'timings'},
      path: '${directory.path}/${userController.currentUser.value.userID!}',
    );

    final CollectionBox box = await collection.openBox<Map>('timings');
    await box.put(currentAudioBook.value.audioBookID!, {'seconds': seconds});
  }

  Future<num> getAudioBookProgress(String audioBookID) async {
    final directory = await getApplicationDocumentsDirectory();
    final userController = Get.find<UserController>();
    final BoxCollection collection = await BoxCollection.open(
      'OdiyoDB',
      {'timings'},
      path: '${directory.path}/${userController.currentUser.value.userID!}',
    );

    final CollectionBox box = await collection.openBox<Map>('timings');
    final audioBook = await box.get(audioBookID);
    if (audioBook == null) {
      return 0;
    }
    return audioBook['seconds'] ?? 0;
  }
}
