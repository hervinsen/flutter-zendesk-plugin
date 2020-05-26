import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;
  Debouncer({this.milliseconds});

  Future<void> run(VoidCallback action) async {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
