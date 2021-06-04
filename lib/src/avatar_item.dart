import 'package:rive/rive.dart';

class AvatarItem {
  String rivFilePath;

  AvatarItem(this.rivFilePath, {this.make});

  Rive Function(Artboard) make;
}
