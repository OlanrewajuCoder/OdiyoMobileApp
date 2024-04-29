import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/screens/audiobooks/seek_bar.dart';
import 'package:odiyo/services/player_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/loading.dart';
import 'package:odiyo/widgets/rating_bar.dart';

class MyPlayer extends StatefulWidget {
  final AudioBook audioBook;

  const MyPlayer({Key? key, required this.audioBook}) : super(key: key);

  @override
  State<MyPlayer> createState() => _MyPlayerState();
}

class _MyPlayerState extends State<MyPlayer> {
  final playerService = Get.find<PlayerService>();
  final utilService = Get.find<UtilService>();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    try {
      if (currentAudioBook.value.audioBookID != widget.audioBook.audioBookID) {
        currentAudioBook.value = widget.audioBook;
        await playerService.initAudioBook();
      } else {
        await audioPlayer.stop();
        audioPlayer.playlistPlayAtIndex(index.value);
      }
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text("Now Playing")),
        body: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CachedNetworkImage(
                  imageUrl: widget.audioBook.poster!,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  MyRatingBar(rating: widget.audioBook.rating!.toDouble(), ratingsCount: widget.audioBook.ratingsCount!),
                  const SizedBox(height: 15),
                  Text(widget.audioBook.title!.toUpperCase(), textScaleFactor: 1.2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  StreamBuilder(
                      stream: audioPlayer.realtimePlayingInfos,
                      builder: (context, AsyncSnapshot<RealtimePlayingInfos> snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final info = snapshot.data!;
                        int? chapterIndex = info.current?.playlist.currentIndex;

                        return chapterIndex == null
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  Text(widget.audioBook.chapterTitles![chapterIndex], textScaleFactor: 1.1, style: const TextStyle(color: primaryColor)),
                                  const SizedBox(height: 30),
                                  PositionSeekWidget(
                                    seekTo: (to) {
                                      audioPlayer.seek(to);
                                    },
                                    duration: info.duration,
                                    currentPosition: info.currentPosition,
                                  ),
                                ],
                              );
                      }),
                  const SizedBox(height: 20),
                  PlayerBuilder.isBuffering(
                    player: audioPlayer,
                    builder: (context, isBuffering) {
                      if (isBuffering) {
                        return const LoadingData();
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            previousButton(),
                            playIcon(),
                            nextButton(),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  playIcon() {
    return PlayerBuilder.isPlaying(
      player: audioPlayer,
      builder: (context, isPlaying) {
        return SizedBox(
          height: 70,
          width: 70,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async => await playerService.playOrPause(),
            icon: Icon(isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_rounded, size: 60),
          ),
        );
      },
    );
  }

  bool nextDone = true;
  bool previousDone = true;

  previousButton() {
    return IconButton(
      icon: const Icon(Icons.skip_previous_rounded, size: 35),
      onPressed: () async {
        if (previousDone) {
          previousDone = false;
          await playerService.previous();
          previousDone = true;
        }
      },
    );
  }

  nextButton() {
    return IconButton(
      icon: const Icon(Icons.skip_next, size: 35),
      onPressed: () async {
        if (nextDone) {
          nextDone = false;
          await playerService.next();
          nextDone = true;
        }
      },
    );
  }
}
