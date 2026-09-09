import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart'
    if (dart.library.io) 'file_download_mobile.dart';

class FileDownloadHelper {
  static Future<void> downloadFile({
    required List<int> bytes,
    required String fileName,
    required String shareText,
  }) async {
    await saveAndShareFile(
      bytes: bytes,
      fileName: fileName,
      text: shareText,
    );
  }
}
