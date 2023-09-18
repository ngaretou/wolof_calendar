import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
// import 'dart:typed_data';
// import 'package:flutter/services.dart' show rootBundle;

import 'scripture_panel.dart';

class PlayButton extends StatefulWidget {
  final String file;
  //child method called via this
  final ChildController childController;

  const PlayButton(
      {Key? key, required this.file, required this.childController})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  PlayButtonState createState() => PlayButtonState(childController);
}

class PlayButtonState extends State<PlayButton> with WidgetsBindingObserver {
  PlayButtonState(ChildController childController) {
    childController.childMethod = stopFromParent;
  }

  final _player = AudioPlayer();
  List<AudioSource> source = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSession();
  }

  Future _initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future _loadAudio() async {
    // print('loading local audio ${widget.file.toString()}');

    try {
      await _player.setAudioSource(AudioSource.uri(
          Uri.parse("asset:///assets/audio/${widget.file}.mp3")));
    } catch (e) {
      debugPrint('an error occurred loading audio: ${e.toString()}');
    }

    // Future<void> checkAndAddAudioSource(String path) async {
    //   late bool fileExists;
    //   try {
    //     //rootBundle.load gives an error if the file does not exist, and that gives you false
    //     // ignore: unused_local_variable
    //     ByteData bytes = await rootBundle.load('assets/audio/$path');
    //     fileExists = true;
    //     print(' fileExists = true;');
    //   } catch (e) {
    //     fileExists = false;
    //     print(' fileExists = false;');
    //   }

    //   if (fileExists) {
    //     // source.clear();
    //     // source.add(AudioSource.uri(Uri.parse("asset:///assets/audio/$path")));

    //     try {
    //       await _player.setAudioSource(
    //           AudioSource.uri(Uri.parse("asset:///assets/audio/$path")));
    //     } catch (e) {
    //       print('an error occurred loading audio: ${e.toString()}');
    //     }
    //   }
    // }

    // await checkAndAddAudioSource('${widget.file}.mp3');

    // try {
    //   await _player.setAudioSource(
    //     ConcatenatingAudioSource(
    //       // Start loading next item just before reaching it.
    //       useLazyPreparation: true, // default
    //       // Customise the shuffle algorithm.
    //       shuffleOrder: DefaultShuffleOrder(), // default
    //       // Specify the items in the playlist.

    //       children: source,
    //     ),
    //     // Playback will be prepared to start from track1.mp3
    //     initialIndex: 0, // default
    //     // Playback will be prepared to start from position zero.
    //     initialPosition: Duration.zero, // default
    //   );
    // } catch (e) {
    //   print('an error occurred loading audio: ${e.toString()}');
    // }

    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  Future<void> gracefulStop() async {
    if (_player.playing) {
      // print('gracefulStop');
      for (var i = 10; i >= 0; i--) {
        _player.setVolume(i / 10);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      await _player.stop();
      _player.seek(Duration.zero);
    }
  }

  void stopFromParent() {
    if (_player.playing) {
      // print('stopFromParent');

      // _player.stop();
      gracefulStop();
    }
  }

  @override
  void dispose() {
    // print('disposing play button for ${widget.file}');
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //If the user presses home then the audio will stop gracefully
    if (state == AppLifecycleState.paused) {
      // _player.stop();
      gracefulStop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('building play button for ${widget.file}');
    if (_player.playing) {
      // _player.stop();
      gracefulStop();
    }
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        bool? playing = playerState?.playing;

        if (playing != true) {
          return IconButton.filled(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                _loadAudio();
                _player.setVolume(1);
                _player.play();
              });
        } else if (processingState != ProcessingState.completed) {
          return IconButton.filled(
              icon: const Icon(Icons.pause),
              onPressed: () {
                _player.pause();
              });
        } else {
          // print(_player.playing);
          return IconButton.filled(
            icon: const Icon(Icons.play_arrow),
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
