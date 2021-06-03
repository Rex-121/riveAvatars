
import 'package:avatars/src/avatar_file_mixin.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rxdart/subjects.dart';

class AudioPlay extends StatefulWidget {
  AudioPlay({Key key}) : super(key: key);

  final _AudioPlayState state = _AudioPlayState();

  @override
  _AudioPlayState createState() => state;

  /// 开始/停止播放
  void toggle() => state.toggle();
}

class _AudioPlayState extends State<AudioPlay> with AvatarFileMixin {
  final BehaviorSubject<bool> _readyStream = BehaviorSubject();

  StateMachineController _controller;

  SMIInput<bool> _isPlaying;

  Artboard _artboard;

  /// 开始/停止播放
  void toggle() {
    _isPlaying.value = !_isPlaying.value;
  }

  @override
  void initState() {
    loadFile('img/AudioPlay.riv').take(1).map((event) => event.mainArtboard).listen(
      (mainArtboard) {
        _artboard = mainArtboard;
        _controller =
            StateMachineController.fromArtboard(_artboard, 'State Machine 1');
        if (_controller != null) {
          _artboard.addController(_controller);
          _isPlaying = _controller.findInput('isPlaying');
        }
        _readyStream.add(true);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _readyStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _readyStream.stream,
        builder: (_, snap) {
          if (!snap.hasData) return Container();

          return Rive(
            artboard: _artboard,
          );
        });
  }
}
