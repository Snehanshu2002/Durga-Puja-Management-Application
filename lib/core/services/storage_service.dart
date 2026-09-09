import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:durgapuja_manager/core/error/app_exception.dart';

class UploadResult {
  final String url;
  final String path;

  const UploadResult({required this.url, required this.path});
}

class StorageService {
  final FirebaseStorage _storage;

  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  StorageService([FirebaseStorage? storage])
      : _storage = storage ?? FirebaseStorage.instance;

  String _getMimeType(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  Future<UploadResult> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String storagePath,
    required Map<String, String> customMetadata,
  }) async {
    if (bytes.isEmpty) {
      throw const AppException(
        'Selected image file is empty or unreadable. Please try selecting the image again.',
      );
    }

    if (bytes.length > maxFileSizeBytes) {
      throw const AppException(
        'File size exceeds the 5 MB limit. Please select a smaller image.',
      );
    }

    final String mimeType = _getMimeType(fileName);

    try {
      final Reference ref = _storage.ref().child(storagePath);

      final SettableMetadata metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: customMetadata,
      );

      final TaskSnapshot snapshot = await ref.putData(bytes, metadata).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw const AppException(
          'Upload timed out. Please check your internet connection and try again.',
        ),
      );

      final String downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw const AppException(
          'Failed to get download URL. Please try again.',
        ),
      );

      return UploadResult(url: downloadUrl, path: storagePath);
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw AppException(
        'Firebase Storage error [${e.code}]: ${e.message ?? e.code}',
      );
    } catch (e) {
      throw AppException('Upload failed: ${e.toString()}');
    }
  }

  Future<UploadResult> uploadCollectionReceipt({
    required XFile file,
    required String eventId,
    required String collectionId,
    Uint8List? preloadedBytes,
  }) async {
    final targetEventId = eventId.trim().isNotEmpty ? eventId.trim() : 'bhasani_utsab_2026';
    if (collectionId.trim().isEmpty) {
      throw const AppException('Collection ID is required for file upload.');
    }

    final Uint8List bytes = preloadedBytes ?? await file.readAsBytes();
    final String sanitizedName = _sanitizeFileName(file.name);
    final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String storagePath =
        'events/$targetEventId/collections/$collectionId/receipts/${timeStamp}_$sanitizedName';

    return uploadBytes(
      bytes: bytes,
      fileName: file.name,
      storagePath: storagePath,
      customMetadata: {
        'eventId': targetEventId,
        'collectionId': collectionId,
      },
    );
  }

  Future<UploadResult> uploadExpenseVoucher({
    required XFile file,
    required String eventId,
    required String expenseId,
    Uint8List? preloadedBytes,
  }) async {
    final targetEventId = eventId.trim().isNotEmpty ? eventId.trim() : 'bhasani_utsab_2026';
    if (expenseId.trim().isEmpty) {
      throw const AppException('Expense ID is required for file upload.');
    }

    final Uint8List bytes = preloadedBytes ?? await file.readAsBytes();
    final String sanitizedName = _sanitizeFileName(file.name);
    final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String storagePath =
        'events/$targetEventId/expenses/$expenseId/vouchers/${timeStamp}_$sanitizedName';

    return uploadBytes(
      bytes: bytes,
      fileName: file.name,
      storagePath: storagePath,
      customMetadata: {
        'eventId': targetEventId,
        'expenseId': expenseId,
      },
    );
  }
}
