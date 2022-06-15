import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class PlayButton extends StatefulWidget {
  final String file;
  final String name;

  const PlayButton({Key? key, required this.file, required this.name})
      : super(key: key);

  @override
  PlayButtonState createState() => PlayButtonState();
}

class PlayButtonState extends State<PlayButton> with WidgetsBindingObserver {
  final _player = AudioPlayer();
  List<AudioSource> source = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _initializeSession();
  }

  Future _initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    print('loading local audio ${widget.file.toString()}');

    Future<void> checkAndAddAudioSource(String path) async {
      late bool fileExists;
      try {
        //rootBundle.load gives an error if the file does not exist, and that gives you false
        // ignore: unused_local_variable
        ByteData bytes = await rootBundle.load('assets/audio/$path');
        fileExists = true;
        print(' fileExists = true;');
      } catch (e) {
        fileExists = false;
        print(' fileExists = false;');
      }

      if (fileExists) {
        source.add(AudioSource.uri(Uri.parse("asset:///assets/audio/$path")));
      }
    }

    if (widget.name != '0') {
      // source = [
      //   AudioSource.uri(
      //       Uri.parse("asset:///assets/audio/names/${widget.name}.mp3")),
      //   AudioSource.uri(Uri.parse("asset:///assets/audio/${widget.file}.mp3")),
      // ];
      await checkAndAddAudioSource('names/${widget.name}.mp3');
      await checkAndAddAudioSource('${widget.file}.mp3');
    } else {
      // source = [
      //   AudioSource.uri(Uri.parse("asset:///assets/audio/${widget.file}.mp3")),
      // ];
      await checkAndAddAudioSource('${widget.file}.mp3');
    }

    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          // Start loading next item just before reaching it.
          useLazyPreparation: true, // default
          // Customise the shuffle algorithm.
          shuffleOrder: DefaultShuffleOrder(), // default
          // Specify the items in the playlist.

          children: source,
        ),
        // Playback will be prepared to start from track1.mp3
        initialIndex: 0, // default
        // Playback will be prepared to start from position zero.
        initialPosition: Duration.zero, // default
      );
    } catch (e) {
      print('an error occurred loading audio: ${e.toString()}');
    }

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
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _player.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //If the user presses home then the audio will stop gracefully
    if (state == AppLifecycleState.paused) {
      gracefulStop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (playing != true) {
          return FloatingActionButton(
              child: const Icon(Icons.play_arrow),
              onPressed: () async {
                await _initializeSession();

                _player.play();
              });
        } else if (processingState != ProcessingState.completed) {
          return FloatingActionButton(
              child: const Icon(Icons.pause),
              onPressed: () {
                _player.pause();
              });
        } else {
          return FloatingActionButton(
            child: const Icon(Icons.play_arrow),
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
