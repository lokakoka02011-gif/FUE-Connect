import 'dart:typed_data';
import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static Future<String?> uploadImage(
    XFile image,
    String folder,
  ) async {
    try {
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance
          .ref()
          .child(folder)
          .child('$fileName.jpg');

      if (kIsWeb) {
        Uint8List bytes = await image.readAsBytes();
        await ref.putData(bytes);
      } else {
        await ref.putFile(File(image.path));
      }

      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }
}