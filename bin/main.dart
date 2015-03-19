import "dart:io";
import "package:assets_and_binary_repositories/assets.dart";

main() async {
  var assets = await Assets.install();
  print("Assets: $assets");
  for (var file in new Directory(assets).listSync(recursive: true)) {
    print(file.path);
  }
}
