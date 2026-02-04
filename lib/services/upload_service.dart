import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class UploadService {
  static const server = "http://192.168.100.96:8080";

  static Future<void> uploadFile(
    PlatformFile file, {
    required Function(double) onProgress,
  }) async {
    final stream = file.readStream!;
    final size = file.size;
    final chunkSize = 1024 * 1024; // 1MB
    int sent = 0;

    final hash = await _calculateHash(file);

    int index = 0;
    await for (final chunk in stream) {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$server/upload-chunk"),
      );

      request.fields.addAll({
        "filename": file.name,
        "index": index.toString(),
        "hash": hash,
        "totalSize": size.toString(),
      });

      request.files.add(http.MultipartFile.fromBytes("chunk", chunk));

      await request.send();

      sent += chunk.length;
      index++;

      onProgress(sent / size);
    }
  }

  static Future<String> _calculateHash(PlatformFile file) async {
    final bytes = await File(file.path!).readAsBytes();
    return sha256.convert(bytes).toString();
  }
}
