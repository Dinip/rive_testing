import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

const _riveBuildSubpath = 'build/rive_native/native/build';
const _lockTimeout = Duration(seconds: 120);
const _pollInterval = Duration(seconds: 2);

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  final currentPath = Directory.current.path;
  final rootPath = _resolveRootProjectPath(currentPath);

  debugPrint("currentPath: $currentPath");
  debugPrint("rootPath: $rootPath");

  await _ensureRiveNativeBuild(rootPath);

  if (currentPath != rootPath) {
    _ensureSymlink(from: '$currentPath/$_riveBuildSubpath', to: '$rootPath/$_riveBuildSubpath');
  }

  final buildDir = Directory('$currentPath/$_riveBuildSubpath');
  if (buildDir.existsSync()) {
    debugPrint('Contents of build directory:');
    buildDir.listSync(recursive: true).forEach((entity) {
      if (entity is File) debugPrint('File: ${entity.path} (${entity.lengthSync()} bytes, ${entity.statSync().modeString()})');
    });
  } else {
    debugPrint('Build directory does not exist at expected path: ${buildDir.path}');
  }

  await testMain();
}

String _resolveRootProjectPath(String currentPath) {
  final clusterIndex = currentPath.indexOf('/clusters/');
  return clusterIndex != -1 ? currentPath.substring(0, clusterIndex) : currentPath;
}

Future<void> _ensureRiveNativeBuild(String rootPath) async {
  final buildDir = Directory('$rootPath/$_riveBuildSubpath');
  const minBuildSize = 10 * 1024 * 1024; // 10 MB threshold to consider build files valid
  if (buildDir.existsSync() && _getDirectorySize(buildDir) > minBuildSize) {
    debugPrint('Rive native build files found, skipping setup. -> ${_getDirectorySize(buildDir)} bytes');
    return;
  }

  final lockFile = File('$rootPath/build/rive_native_setup.lock');

  if (lockFile.existsSync()) {
    await _waitForBuild(buildDir);
    return;
  }

  try {
    lockFile.parent.createSync(recursive: true);
    lockFile.createSync(exclusive: true);
  } on FileSystemException {
    await _waitForBuild(buildDir);
    return;
  }

  try {
    debugPrint("Installing for platform ${Platform.operatingSystem}");
    debugPrint('Rive native build files not found, running setup command...');
    final result = await Process.run('dart', [
      'run',
      'rive_native:setup',
      '--verbose',
      '--clean',
      '--platform',
      (Platform.operatingSystem),
    ], workingDirectory: rootPath);
    debugPrint('rive_native:setup stdout:\n${result.stdout}');
    if (result.exitCode != 0) {
      throw Exception('Failed to setup rive native build files:\n${result.stderr}');
    }
  } finally {
    try {
      lockFile.deleteSync();
    } on FileSystemException {
      debugPrint('Warning: Failed to delete lock file at ${lockFile.path}. It may need to be removed manually.');
    }
  }
}

/// Polls until the build directory appears or times out.
Future<void> _waitForBuild(Directory buildDir) async {
  final deadline = DateTime.now().add(_lockTimeout);
  while (DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(_pollInterval);
    debugPrint('Waiting for rive native setup by another process...');
    if (buildDir.existsSync()) return;
  }
  throw Exception('Timed out waiting for rive native setup by another process.');
}

void _ensureSymlink({required String from, required String to}) {
  if (Directory(from).existsSync()) return;

  Directory(from).parent.createSync(recursive: true);
  Link(from).createSync(to);
  debugPrint('Created symlink: $from -> $to');
}

int _getDirectorySize(Directory dir) {
  if (!dir.existsSync()) return 0;
  int size = 0;
  final files = dir.listSync(recursive: true);
  for (final file in files) {
    if (file is File) size += file.lengthSync();
  }
  return size;
}
