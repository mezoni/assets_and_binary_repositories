import "package:barback/barback.dart";
import "package:assets_and_binary_repositories/assets.dart";
import "package:path/path.dart" as lib_path;

class AssetsUpdater extends Transformer {
  static const String EXT = ".inf";

  static const String PACKAGE = "assets_and_binary_repositories";

  final BarbackSettings _settings;

  AssetsUpdater.asPlugin(this._settings);

  String get allowedExtensions => EXT;

  Object apply(Transform transform) async {
    var id = transform.primaryInput.id;
    if (id.package != PACKAGE) {
      return null;
    }

    var filepath = id.path;
    if (lib_path.basename(filepath) != "$PACKAGE$EXT") {
      return null;
    }

    await Assets.update();
    return null;
  }
}
