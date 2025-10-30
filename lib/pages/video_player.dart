import 'package:bilitv/apis/bilibili.dart'
    show getVideoPlayURL, bilibiliHttpClient;
import 'package:bilitv/models/video.dart';
import 'package:bilitv/storages/cookie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerPage extends StatefulWidget {
  final VideoInfo video;

  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  FocusNode focusNode = FocusNode();
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    getVideoPlayURL(
      avid: widget.video.avid,
      cid: widget.video.cid,
      quality: loginNotifier.value ? 64 : 32,
    ).then((infos) {
      setState(() {
        player.open(
          Media(
            infos.first.urls.first,
            httpHeaders: bilibiliHttpClient.options.headers
                .cast<String, String>(),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 9.0 / 16.0,
          child: KeyboardListener(
            autofocus: true,
            focusNode: focusNode,
            onKeyEvent: _onKeyEvent,
            child: Video(controller: controller),
          ),
        ),
      ),
    );
  }

  void _onKeyEvent(KeyEvent value) {
    if (value.runtimeType == KeyUpEvent) {
      return;
    }
    final step = Duration(seconds: 5);
    if (value.logicalKey == LogicalKeyboardKey.select ||
        value.logicalKey == LogicalKeyboardKey.enter) {
      player.playOrPause();
    } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (player.state.position < step) {
        player.seek(Duration(seconds: 0));
      } else {
        player.seek(player.state.position - step);
      }
    } else if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (player.state.duration - player.state.position < step) {
        player.seek(player.state.duration);
      } else {
        player.seek(player.state.position + step);
      }
    }
  }
}
