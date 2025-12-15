import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fisherman_pro/database/message_service.dart';
import 'package:fisherman_pro/database/storage.dart';
import 'package:motion_toast/motion_toast.dart';

class CreateMessagePage extends StatefulWidget {
  const CreateMessagePage({super.key});

  @override
  State<CreateMessagePage> createState() => _CreateMessagePageState();
}

class _CreateMessagePageState extends State<CreateMessagePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final MessageService _messageService = MessageService();
  final StorageCloud _storage = StorageCloud();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  bool _isLoading = false;
  bool _withLocation = false;
  double? _latitude;
  double? _longitude;

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _takePhoto() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _withLocation = true;
      _latitude = 55.7558;
      _longitude = 37.6173;
      _addressController.text = 'Москва, Красная площадь';
    });
  }

  Future<void> _submitMessage() async {
    if (_textController.text.isEmpty && _selectedImage == null) {
      MotionToast.error(
        description: Text('Добавьте текст или фото'),
      ).show(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _storage.uploadImage(_selectedImage!);

        if (imageUrl == null) {
          MotionToast.error(
            description: Text('Не удалось загрузить фото'),
          ).show(context);
          setState(() => _isLoading = false);
          return;
        }
      }

      await _messageService.sendMessage(
        _textController.text.isNotEmpty ? _textController.text : null,
        imageUrl,
        _withLocation ? _latitude : null,
        _withLocation ? _longitude : null,
        _addressController.text.isNotEmpty ? _addressController.text : null,
      );

      MotionToast.success(
        description: Text('Отчет опубликован!'),
      ).show(context);
      Navigator.pop(context);
    } catch (e) {
      print('❌ Ошибка публикации: $e');
      MotionToast.error(description: Text('Ошибка: $e')).show(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Новый отчет', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Поделитесь своим уловом',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Фото улова (необязательно)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12),

                  if (_selectedImage == null)
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 50,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Нет фотографии',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    FutureBuilder<Uint8List>(
                      future: _selectedImage!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // Используем AspectRatio для сохранения пропорций фото
                          return Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxHeight: 400, // Максимальная высота
                                ),
                                child: AspectRatio(
                                  aspectRatio: 4 / 3, // Сохраняем пропорции 4:3
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() => _selectedImage = null);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Container(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.grey.shade800,
                            ),
                          ),
                        );
                      },
                    ),

                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.photo_library, color: Colors.white),
                          label: Text('Галерея'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _takePhoto,
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          label: Text('Камера'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _withLocation,
                        onChanged: (value) {
                          setState(() => _withLocation = value ?? false);
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Добавить местоположение',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                      if (!_withLocation)
                        ElevatedButton.icon(
                          onPressed: _getLocation,
                          icon: Icon(Icons.location_on, color: Colors.white),
                          label: Text('Определить'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                          ),
                        ),
                    ],
                  ),

                  if (_withLocation) ...[
                    SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Название места (озеро, река...)',
                        prefixIcon: Icon(
                          Icons.place,
                          color: Colors.grey.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade800),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Комментарий к улову*',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Что поймали, на что ловили, какая была погода...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Опубликовать отчет',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
