import 'dart:io';
import 'dart:typed_data';
import 'file_saver_interface.dart';

FileSaver createFileSaver() => FileSaverIO();

class FileSaverIO implements FileSaver {
  @override
  Future<String> saveAndOpenFile({
    required Uint8List bytes,
    required String filename,
  }) async {
    final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
    Directory targetDir;

    if (userProfile != null) {
      final downloads = Directory('$userProfile\\Downloads');
      if (downloads.existsSync()) {
        targetDir = downloads;
      } else {
        targetDir = Directory(userProfile);
      }
    } else {
      targetDir = Directory.current;
    }

    final file = File('${targetDir.path}\\$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
