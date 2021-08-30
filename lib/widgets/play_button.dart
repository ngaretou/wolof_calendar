// @dart=2.9

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
    //allows you to observe the AppLifecycleState below so you can stop the
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    //dispose triggers on popping the page, so stops the audio player playing
    _stopPlayOnExit();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopPlayOnExit();
    }
    if (state == AppLifecycleState.resumed) {
      //This setState just refreshes the view - if it was playing on pause and exits,
      //this gets the play button back to pause as isPlaying was put to false in _stopPlayOnExit();
      //A bit of a strange case though -
      //in testing found that if you go back (pop the route), come back, play, then minimize,
      //thus pausing the app as above and then resume it throws a "setState() called after dispose()" error,
      //so this just quickly checks if the widget is mounted and setState if it is.
      if (this.mounted) {
        setState(() {});
      }
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

  void _stopPlayOnExit() {
    if (isPlaying) {
      player.stop();
      //here just change isPlaying to false -
      //it gets reflected on the screen on resume in didChangeAppLifecycleState on setState
    }
    isPlaying = false;
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

    //This is the IconButton version of this widget, not used here but included for reference.
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
