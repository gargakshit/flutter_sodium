import 'dart:ffi';
import 'dart:io';

import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:path/path.dart' as path show join;

final libsodium = _load();

DynamicLibrary _load() {
  // This fork loads the libsodium library bundled with the application

  if (Platform.isAndroid) {
    return DynamicLibrary.open('libsodium.so');
  }
  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }
  if (Platform.isMacOS) {
    // assuming user installed libsodium as per the installation instructions
    // see also https://libsodium.gitbook.io/doc/installation
    return DynamicLibrary.open('libsodium.dylib');
  }
  if (Platform.isLinux) {
    // assuming user installed libsodium as per the installation instructions
    // see also https://libsodium.gitbook.io/doc/installation
    final executableDir = Platform.resolvedExecutable.split('/');
    executableDir.removeLast();

    final libPath = path.join(
      executableDir.join('/'),
      'lib/libsodium.so',
    );

    return DynamicLibrary.open(libPath);
  }
  if (Platform.isWindows) {
    // assuming user installed libsodium as per the installation instructions
    // see also https://py-ipv8.readthedocs.io/en/latest/preliminaries/install_libsodium/
    return DynamicLibrary.open('libsodium.dll');
  }
  throw SodiumException('platform not supported');
}

// Extension helper for functions returning size_t
// this is a workaround for size_t not being properly supported in ffi. IntPtr
// almost works, but is sign extended.
extension Bindings on DynamicLibrary {
  int Function() lookupSizet(String symbolName) => sizeOf<IntPtr>() == 4
      ? this.lookup<NativeFunction<Uint32 Function()>>(symbolName).asFunction()
      : this.lookup<NativeFunction<Uint64 Function()>>(symbolName).asFunction();
}
