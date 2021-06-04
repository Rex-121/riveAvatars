import 'package:avatars/src/avatar_file_mixin.dart';
import 'package:avatars/src/avatar_item.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class AudioPlayRived extends StatefulWidget {
  final AvatarItem item;

  AudioPlayRived({@required this.item, Key key}) : super(key: key);

  final _AudioPlayState state = _AudioPlayState();

  @override
  _AudioPlayState createState() => state;

  /// 开始/停止播放
  void toggle({@required bool isPlay}) => state.toggle(isPlay);
}

class _AudioPlayState extends State<AudioPlayRived> with AvatarFileMixin {
  final BehaviorSubject<bool> _readyStream = BehaviorSubject();

  final BehaviorSubject<bool> _soundBeforeLoaded = BehaviorSubject();

  final BehaviorSubject<SMIInput<bool>> _playInput = BehaviorSubject();

  StateMachineController _controller;

  CompositeSubscription _allBag = CompositeSubscription();

  Artboard _artboard;

  /// 开始/停止播放
  void toggle(bool isPlay) {
    _soundBeforeLoaded.add(isPlay);
  }

  @override
  void initState() {
    Rx.combineLatest2(_soundBeforeLoaded.distinct(), _playInput,
            (bool isPlay, SMIInput<bool> input) => input.value = isPlay)
        .listen((_) {})
        .addTo(_allBag);

    loadFile(widget.item.rivFilePath)
        .take(1)
        .map((event) => event.mainArtboard)
        .listen(
      (mainArtboard) {
        _artboard = mainArtboard;
        _controller =
            StateMachineController.fromArtboard(_artboard, 'State Machine 1');
        if (_controller != null) {
          _artboard.addController(_controller);
          SMIInput<bool> _isPlaying = _controller.findInput('isPlaying');
          if (_isPlaying != null) {
            _playInput.add(_isPlaying);
            _playInput.close();
          }
        }
        _readyStream.add(true);
      },
    ).addTo(_allBag);
    super.initState();
  }

  @override
  void dispose() {
    _allBag.dispose();
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
