import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class ImageInput extends StatefulWidget {
  final Function onSelectImage;

  ImageInput(this.onSelectImage);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {  
  File? _storedImage;

  _takePicture() async {
    final ImagePicker _picker = ImagePicker();

    //diálogo para escolher entre câmera e galeria
    final ImageSource? imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Escolha a fonte da imagem'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            child: Text('Câmera'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            child: Text('Galeria'),
          ),
        ],
      ),
    );

    if (imageSource == null) return; //cancelou a escolha

    XFile? imageFile;
    
    if (imageSource == ImageSource.camera) {
      imageFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
      ) as XFile?;
    } else if (imageSource == ImageSource.gallery) {
      imageFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      ) as XFile?;
    }

    if (imageFile == null) return;

    setState(() {
      _storedImage = File(imageFile!.path);
    });

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    String fileName = path.basename(_storedImage!.path);
    final savedImage = await _storedImage!.copy('${appDir.path}/$fileName');
    widget.onSelectImage(savedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 180,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          alignment: Alignment.center,
          //child: Text('Nenhuma imagem!'),
          //verificar se tem imagem
          child: _storedImage != null
              ? Image.file(
                  _storedImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : const Text('Nenhuma Imagem!'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.camera),
            label: const Text('Tirar foto'),
            onPressed: _takePicture,
          ),
        ),
      ],
    );
  }
}