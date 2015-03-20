library example_of_usage_of_assets.assets;

import "dart:async";
import "dart:io";

import "package:archive/archive.dart";
import "package:binary_repositories/binary_repositories.dart";
import "package:path/path.dart" as lib_path;

class Assets {
  static final String constraint = "<=1.0.0";
  static final String filepath = "assets.zip";
  static final String package = "assets_and_binary_repositories.assets";

  static Future<String> install() async {
    var pub = new PubBinaryRepository();
    var pm = new PackageManager();
    var versioning = new SemanticVersioningProvider();
    Uri url = await pm.resolve(pub, package, filepath, constraint, versioning);
    if (url == null) {
      return await update();
    }

    return lib_path.dirname(url.toFilePath());
  }

  static Future<String> update() async {
    var pub = new PubBinaryRepository();
    var provider = new FileBasedPackageProvider("packages", "packages.lst", "versions.lst");
    var github = new GitHubRawRepository("mezoni", "binaries", provider);
    var pm = new PackageManager();
    var versioning = new SemanticVersioningProvider();
    IntallationResult result = await pm.install(github, pub, package, filepath, constraint, versioning);
    Uri url = await pm.resolve(pub, package, filepath, constraint, versioning);
    if (url == null) {
      _error(package, filepath, constraint);
      return null;
    }

    if (result.newVersion != null) {
      var archive = url.toFilePath();
      var success = false;
      try {
        _unzip(archive);
        success = true;
      } finally {
        if (!success) {
          new File(archive).deleteSync();
          _error(package, filepath, constraint);
          return null;
        }
      }
    }

    return lib_path.dirname(url.toFilePath());
  }

  static void _error(String package, String filepath, String constraint) {
    throw new StateError("Assets not found: $package($constraint)");
  }

  static void _unzip(String path) {
    var dirname = lib_path.dirname(path);
    var bytes = new File(path).readAsBytesSync();
    var archive = new ZipDecoder().decodeBytes(bytes);
    for (var file in archive.files) {
      var content = file.content;
      var path = lib_path.join(dirname, file.name);
      new File(path).writeAsBytesSync(bytes);
    }
  }
}
