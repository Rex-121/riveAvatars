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
            return Rive(artboard: event);
          })
          .listen((event) => mainAnimationWidget.add(event))
          .addTo(_avatarBag);

      /// 读取文件
      _loadFile(avatarItem.rivFilePath)
          .take(1)
          .map((event) => event.mainArtboard)
          .listen((event) => mainArtBoard.add(event))
          .addTo(_avatarBag);
    }

    super.initState();
  }

  @override
  void dispose() {
    _avatarBag.dispose();
    super.dispose();
  }
}
