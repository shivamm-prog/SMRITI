import 'dart:typed_data';
import 'file_saver_interface.dart';

FileSaver createFileSaver() => FileSaverStub();

class FileSaverStub implements FileSaver {
  @override
  Future<String> saveAndOpenFile({
    required Uint8List bytes,
    required String filename,
  }) async {
    return filename;
  }
}
