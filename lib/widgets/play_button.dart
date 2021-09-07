import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
// import 'package:path_provider/path_provider.dart';

// https://pub.dev/packages/just_audio/example

class PlayButton extends StatefulWidget {
  final String file;
  PlayButton({Key? key, required this.file}) : super(key: key);

  @override
  PlayButtonState createState() => PlayButtonState();
}

class PlayButtonState extends State<PlayButton> with WidgetsBindingObserver {
  final _player = AudioPlayer();
  // late bool _playerIsInitialized;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _initializeSession();
  }

  Future _initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });

    print('loading local audio');
    await _player.setAudioSource(
        AudioSource.uri(Uri.parse("asset:///assets/audio/${widget.file}.mp3")));
    // try {
    //   print('setting asset uri');
    //   await _player.setAudioSource(AudioSource.uri(
    //       Uri.parse("asset:///assets/audio/${widget.file}.mp3")));
    // } catch (e) {
    //   print("Error loading audio source: $e");
    // }
  }

  void gracefulStop() async {
    for (var i = 10; i >= 0; i--) {
      _player.setVolume(i / 10);
      await Future.delayed(Duration(milliseconds: 100));
    }
    _player.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
//If the user presses home then the audio will stop gracefully
      gracefulStop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ControlButtons(_player);
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  ControlButtons(this.player);

  @override
  Widget build(BuildContext context) {
    return

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 64.0,
            height: 64.0,
            child: CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: player.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return FloatingActionButton(
            child: Icon(Icons.pause),
            onPressed: player.pause,
          );
        } else {
          return FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () => player.seek(Duration.zero),
          );
        }
      },
    );
  }
}
