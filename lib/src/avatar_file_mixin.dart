import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

mixin AvatarFileMixin {
  Future<ByteData> _loadRivFile(String path) => rootBundle.load(path);

  Stream<RiveFile> loadFile(String path) {
    return Stream.fromFuture(_loadRivFile(path))
        .map((data) => RiveFile.import(data));
  }
}
