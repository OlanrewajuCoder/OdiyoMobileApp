import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:odiyo/screens/audiobooks/my_player.dart';

import '../services/player_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlayerBuilder.playerState(
      player: audioPlayer,
      builder: (context, PlayerState playerState) {
        if (playerState == PlayerState.play || playerState == PlayerState.pause) {
          return Miniplayer(
            minHeight: 70,
            maxHeight: 70,
            builder: (height, percentage) => ListTile(
              onTap: () => Get.to(() => MyPlayer(audioBook: currentAudioBook.value)),
              leading: CachedNetworkImage(
                imageUrl: currentAudioBook.value.poster!,
                height: 60,
              ),
              title: Text(currentAudioBook.value.title!),
              subtitle: Obx(() {
                return Text(currentAudioBook.value.chapterTitles![index.value], textScaleFactor: 0.85, overflow: TextOverflow.ellipsis, maxLines: 1);
              }),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      try {
                        await audioPlayer.playOrPause();
                      } catch (t) {
                        debugPrint(t.toString());
                      }
                    },
                    icon: Icon(playerState == PlayerState.play ? Icons.pause : Icons.play_arrow),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      try {
                        await audioPlayer.stop();
                      } catch (t) {
                        debugPrint(t.toString());
                      }
                    },
                    icon: const Icon(Icons.stop),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
