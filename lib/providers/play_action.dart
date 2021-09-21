import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class PlayAction with ChangeNotifier {
  bool _playAction = false;
  bool _repaint = false;

  //Work with a copy of the variable, not the map itself
  bool get playAction {
    print('getting playAction, currently ' + _playAction.toString());
    return _playAction;
  }

  set playAction(bool incoming) {
    print('setting playAction to ' + incoming.toString());
    this._playAction = incoming;
  }

  bool get repaint {
    return _repaint;
  }

  set repaint(bool incoming) {
    this._repaint = incoming;
    if (incoming != true) {
      // notifyListeners();
    }
  }
}
