// https://github.com/chenenyu/flutter_fps
/*
Copyright [2019] [chenenyu]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/scheduler.dart';

/// Fps callback.
typedef FpsCallback = void Function(FpsInfo fpsInfo);

class Fps {
  Fps._();

  static Fps? _instance;

  static Fps? get instance {
    _instance ??= _instance = Fps._();
    // if (_instance == null) {
    //   _instance = Fps._();
    // }
    return _instance;
  }

  /// 1000/60hz ≈ 16.6ms  1000/120hz ≈ 8.3ms
  Duration _thresholdPerFrame =
      const Duration(microseconds: Duration.microsecondsPerSecond ~/ 60);

  double _refreshRate = 60;

  set refreshRate(double rate) {
    if (rate != _refreshRate && rate >= 60) {
      _refreshRate = rate;
      _thresholdPerFrame = Duration(
          microseconds: Duration.microsecondsPerSecond ~/ _refreshRate);
    }
  }

  bool _started = false;
  final List<FpsCallback> _fpsCallbacks = [];

  static const int queueCapacity = 120;
  final ListQueue framesQueue = ListQueue<FrameTiming>(queueCapacity);

  void addFpsCallback(FpsCallback callback) {
    _fpsCallbacks.add(callback);
  }

  void removeFpsCallback(FpsCallback callback) {
    assert(_fpsCallbacks.contains(callback));
    _fpsCallbacks.remove(callback);
  }

  void start() async {
    if (!_started) {
      SchedulerBinding.instance.addTimingsCallback(_onTimingsCallback);
      _started = true;
    }
  }

  void stop() {
    if (_started) {
      SchedulerBinding.instance.removeTimingsCallback(_onTimingsCallback);
      _started = false;
    }
  }

  _onTimingsCallback(List<FrameTiming> timings) async {
    if (_fpsCallbacks.isNotEmpty) {
      for (FrameTiming timing in timings) {
        framesQueue.addFirst(timing);
      }
      while (framesQueue.length > queueCapacity) {
        framesQueue.removeLast();
      }

      List<FrameTiming> drawFrames = [];
      for (FrameTiming timing in framesQueue) {
        if (drawFrames.isEmpty) {
          drawFrames.add(timing);
        } else {
          int lastStart =
              drawFrames.last.timestampInMicroseconds(FramePhase.vsyncStart);
          int interval = lastStart -
              timing.timestampInMicroseconds(FramePhase.rasterFinish);
          if (interval > (_thresholdPerFrame.inMicroseconds * 2)) {
            // maybe in different set
            break;
          }
          drawFrames.add(timing);
        }
      }
      framesQueue.clear();

      // compute total frames count.
      int totalCount = drawFrames.map((frame) {
        // If droppedCount > 0,
        int droppedCount =
            frame.totalSpan.inMicroseconds ~/ _thresholdPerFrame.inMicroseconds;
        return droppedCount + 1;
      }).fold(0, (a, b) => a + b);

      int drawFramesCount = drawFrames.length;
      int droppedCount = totalCount - drawFramesCount;
      double fps = drawFramesCount / totalCount * _refreshRate;
      FpsInfo fpsInfo = FpsInfo(fps, totalCount, droppedCount, drawFramesCount);
      for (var fpscallback in _fpsCallbacks) {
        fpscallback(fpsInfo);
      }
    }
  }
}

class FpsInfo {
  double fps;
  int totalFramesCount;
  int droppedFramesCount;
  int drawFramesCount; //number of frames actually drawn

  FpsInfo(this.fps, this.totalFramesCount, this.droppedFramesCount,
      this.drawFramesCount);

  @override
  String toString() {
    return 'FpsInfo{'
        'fps: $fps, '
        'totalFramesCount: $totalFramesCount, '
        'droppedFramesCount: $droppedFramesCount, '
        'drawFramesCount: $drawFramesCount}';
  }
}
