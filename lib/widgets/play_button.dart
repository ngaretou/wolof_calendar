import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

class Player extends StatefulWidget {
  final String file;

  Player(this.file);
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
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

  void pauseHandler() {
    if (isPaused && isPlaying) {
      player.resume();
    } else {
      player.pause();
    }
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: playHandler,
      child: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
    );

//This is the IconButton version of this widget; FloatingActionButton above; ot
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
