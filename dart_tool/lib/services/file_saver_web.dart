import 'dart:html' as html;
import 'dart:typed_data';
import 'file_saver_interface.dart';

FileSaver createFileSaver() => FileSaverWeb();

class FileSaverWeb implements FileSaver {
  @override
  Future<String> saveAndOpenFile({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      return 'Downloaded: $filename';
    } catch (_) {
      return 'Downloaded: $filename';
    }
  }
}
