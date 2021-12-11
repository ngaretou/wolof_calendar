import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';

class PlayButton extends StatefulWidget {
  final String file;

  PlayButton({Key? key, required this.file}) : super(key: key);

  @override
  PlayButtonState createState() => PlayButtonState();
}

class PlayButtonState extends State<PlayButton> with WidgetsBindingObserver {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _initializeSession();
  }

  Future _initializeSession() async {
    // final session = await AudioSession.instance;
    // await session.configure(AudioSessionConfiguration.speech());

    //**This only rebuilds on setState from the parent if the setAudioSource is in the build method rather than the initState
    print('loading local audio ' + widget.file.toString());

    _player.setAudioSource(
        AudioSource.uri(Uri.parse("asset:///assets/audio/${widget.file}.mp3")));

    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  Future<void> gracefulStop() async {
    print('gracefulStop');
    for (var i = 10; i >= 0; i--) {
      _player.setVolume(i / 10);
      await Future.delayed(Duration(milliseconds: 100));
    }
    _player.pause();
    // dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
// //If the user presses home then the audio will stop gracefully
//       // gracefulStop();
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        //The below if on the ProcessingState works well in case you are downloading from
        //the internet but doesn't work as well with local assets, commenting it out rather
        //than deleting
        // if (processingState == ProcessingState.loading ||
        //     processingState == ProcessingState.buffering) {
        //   return Container(
        //     margin: EdgeInsets.all(8.0),
        //     width: 64.0,
        //     height: 64.0,
        //     child: CircularProgressIndicator(),
        //   );
        // } else

        // if (playing == true && timeToStop) {
        //   print('playing, and time to stop');
        //   gracefulStop();

        //   return FloatingActionButton(
        //       child: Icon(Icons.play_arrow), onPressed: () {});
        // } else
        if (playing != true) {
          return FloatingActionButton(
              child: Icon(Icons.play_arrow),
              onPressed: () {
                _player.play();
              });
        } else if (processingState != ProcessingState.completed) {
          return FloatingActionButton(
              child: Icon(Icons.pause),
              onPressed: () {
                _player.pause();
              });
        } else {
          return FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () {
              print('in the else');
              _player.seek(Duration.zero);
            },
          );
        }
      },
    );
  }
}
