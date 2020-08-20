// import 'package:flutter/material.dart';
// // import 'package:assets_audio_player/assets_audio_player.dart';

// class AudioPlayer extends StatefulWidget {
//   @override
//   _AudioPlayerState createState() => _AudioPlayerState();
// }

// class _AudioPlayerState extends State<AudioPlayer> {
// //inside a stateful widget

//   bool _play = false;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: AudioWidget.assets(
//       path: "assets/audio/1.m4a",
//       play: _play,
//       onFinished: () {
//         print('in on finished');
//         _play = !_play;
//         setState(() {});
//       },
//       child: RaisedButton(
//           child: Text(
//             _play ? "pause" : "play",
//           ),
//           onPressed: () {
//             setState(() {
//               _play = !_play;
//             });
//           }),
//       onReadyToPlay: (duration) {
//         //onReadyToPlay
//       },
//       onPositionChanged: (current, duration) {
//         //onReadyToPlay
//       },
//     ));
//   }
// }
