import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

class Player extends StatefulWidget {
  final String file;

  Player(this.file);
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> with WidgetsBindingObserver {
  //WidgetsBindingObserver helps us see when we close the app and stops the playback.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopPlay();
      print("app exited");
    }
  }

  static AudioCache cache = AudioCache();
  AudioPlayer player;

  bool isPlaying = false;
  bool isPaused = false;

  void playHandler() async {
    if (isPlaying) {
      player.stop();
    } else {
      player = await cache.play('audio/${widget.file}.mp3');
      player.onPlayerCompletion.listen((_) {
        player.stop();
        setState(() {
          if (isPaused) {
            isPlaying = false;
            isPaused = false;
          } else {
            isPlaying = !isPlaying;
          }
        });
      });
    }

    setState(() {
      if (isPaused) {
        isPlaying = false;
        isPaused = false;
      } else {
        isPlaying = !isPlaying;
      }
    });
  }

  void _stopPlay() {
    //? is used to check null, so stop() will be called only if player != null. https://stackoverflow.com/questions/56360083/stop-audio-loop-audioplayers-package
    player?.stop();
    //If you don't setState the button will show the pause icon on resume
    setState(() {
      isPlaying = false;
      isPaused = false;
    });
  }

  //pauseHandler not used in this app but here for reference
  // void pauseHandler() {
  //   if (isPaused && isPlaying) {
  //     player.resume();
  //   } else {
  //     player.pause();
  //   }
  //   setState(() {
  //     isPaused = !isPaused;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: playHandler,
      child: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
    );

//This is the IconButton version of this widget; FloatingActionButton above.
    // IconButton(
    //   icon: Icon(
    //     isPlaying ? Icons.pause : Icons.play_arrow,
    //     color: Colors.white,
    //   ),
    //   onPressed: () {
    //     playHandler();
    //   },
    // );
  }
}
