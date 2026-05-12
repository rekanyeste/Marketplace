import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Helper for picking and converting images to Base64 for Firestore storage.
class ImageHelper {
  static final _picker = ImagePicker();

  /// Pick a single image from gallery.
  static Future<File?> pickFromGallery() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }

  /// Pick multiple images from gallery (up to [maxImages]).
  static Future<List<File>> pickMultipleFromGallery({int maxImages = 2}) async {
    final xfiles = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );
    final files = xfiles.map((x) => File(x.path)).toList();
    if (files.length > maxImages) {
      return files.sublist(0, maxImages);
    }
    return files;
  }

  /// Pick image from camera.
  static Future<File?> pickFromCamera() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }

  /// Convert a File to a Base64 data URI string.
  static Future<String?> fileToBase64(File file) async {
    try {
      final Uint8List bytes;
      if (kIsWeb) {
        bytes = await XFile(file.path).readAsBytes();
      } else {
        bytes = await file.readAsBytes();
      }
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }

  /// Convert multiple files to Base64 data URI strings.
  static Future<List<String>> filesToBase64(List<File> files) async {
    final results = <String>[];
    for (final file in files) {
      final base64 = await fileToBase64(file);
      if (base64 != null) {
        results.add(base64);
      }
    }
    return results;
  }

  /// Convenience: pick and convert a single image to Base64.
  static Future<String?> pickAndConvertToBase64({
    bool fromCamera = false,
  }) async {
    final file = fromCamera ? await pickFromCamera() : await pickFromGallery();
    if (file == null) return null;
    return fileToBase64(file);
  }

  /// Check if a string is a Base64 data URI.
  static bool isBase64DataUri(String? url) {
    if (url == null) return false;
    return url.startsWith('data:image/');
  }

  /// Decode Base64 data URI to bytes for Image.memory().
  static Uint8List? decodeBase64DataUri(String dataUri) {
    try {
      final base64Part = dataUri.split(',').last;
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
  }
}
