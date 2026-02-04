import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  double progress = 0;

  Future<void> pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withReadStream: true,
    );

    if (result == null) return;

    for (final file in result.files) {
      await UploadService.uploadFile(
        file,
        onProgress: (p) {
          setState(() => progress = p);
        },
      );
    }

    setState(() => progress = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UpPhoto")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickAndUpload,
              child: const Text("Seleccionar archivos"),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}
