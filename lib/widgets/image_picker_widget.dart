import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImagePickerWidget extends StatefulWidget {
  final String? initialImagePath;
  final void Function(String? imagePath) onImageSelected;
  const ImagePickerWidget({Key? key, this.initialImagePath, required this.onImageSelected}) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // Copy the image to the app's local directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(picked.path);
      final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');
      setState(() {
        _imagePath = savedImage.path;
      });
      widget.onImageSelected(_imagePath);
    }
  }

  void _chooseDefaultIcon() {
    setState(() {
      _imagePath = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _imagePath != null
            ? Image.file(File(_imagePath!), width: 40, height: 40, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 40, color: Colors.red),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Pick Image'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _chooseDefaultIcon,
          child: const Text('Default Icon', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
} 