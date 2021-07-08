import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';

import 'avatar_item.dart';

mixin AvatarMixin<T extends StatefulWidget> on State<T> {
  AvatarItem avatarItem;

  CompositeSubscription _avatarBag = CompositeSubscription();

  BehaviorSubject<Artboard> mainArtBoard = BehaviorSubject();

  /// 加载动画完成
  BehaviorSubject<Rive> mainAnimationWidget = BehaviorSubject();

  Future<ByteData> _loadRivFile(String path) => rootBundle.load(path);

  Stream<RiveFile> _loadFile(String path) {
    return Stream.fromFuture(_loadRivFile(path))
        .map((data) => RiveFile.import(data));
  }

  /// 核心widget
  StreamBuilder<Widget> rivedWidget() {
    return StreamBuilder<Widget>(
      stream: mainAnimationWidget,
      initialData: Container(),
      builder: (_, snap) => snap.data,
    );
  }

  @override
  void initState() {
    if (avatarItem != null) {
      mainArtBoard
          .map((event) {
            if (avatarItem.make != null) {
              return avatarItem.make(event);
            }
            return Rive(
              artboard: event,
              useArtboardSize: true,
            );
          })
          .listen((event) => mainAnimationWidget.add(event))
          .addTo(_avatarBag);

      /// 读取文件
      _loadFile(avatarItem.rivFilePath)
          .take(1)
          .listen((event) => riveFileDidLoaded(event))
          .addTo(_avatarBag);
    }

    super.initState();
  }

  /// rive文件被读取完毕
  void riveFileDidLoaded(RiveFile rive) {
    artBoardDidLoaded(rive.mainArtboard, rive.artboards);
  }

  /// 画板被读取
  void artBoardDidLoaded(Artboard mainArtboard, List<Artboard> artboards) {
    didAddMainBoardToStage(mainArtboard);
  }

  /// 将默认画板加入舞台
  Artboard didAddMainBoardToStage(Artboard mainArtboard) {
    mainArtBoard.add(mainArtboard);
    return mainArtboard;
  }

  @override
  void dispose() {
    _avatarBag.dispose();
    super.dispose();
  }
}
