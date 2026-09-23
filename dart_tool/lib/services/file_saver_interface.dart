import 'dart:typed_data';

abstract interface class FileSaver {
  Future<String> saveAndOpenFile({
    required Uint8List bytes,
    required String filename,
  });
}
