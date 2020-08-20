import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

class AudioPlayerInstance extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isTrue;
  final String trueText;
  final String falseText;

  AudioPlayerInstance({
    @required this.onPressed,
    @required this.isTrue,
    @required this.trueText,
    @required this.falseText,
  });

  @override
  _AudioPlayerInstanceState createState() => _AudioPlayerInstanceState();
}

class _AudioPlayerInstanceState extends State<AudioPlayerInstance> {
  static AudioCache cache = AudioCache();
  AudioPlayer player;

  bool isPlaying = false;
  bool isPaused = false;

  void playHandler() async {
    if (isPlaying) {
      player.stop();
    } else {
      player = await cache.play('assets/audio/4.m4a');
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
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        width: 70,
        height: 70,
        child: RaisedButton(
          elevation: 10,
          onPressed: widget.onPressed,
          child: Text(widget.isTrue ? widget.trueText : widget.falseText,
              style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
