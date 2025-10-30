import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddRepair extends StatefulWidget {
  final Map<String, dynamic> mkd;
  final Map<String, dynamic> street;

  const AddRepair({super.key, required this.mkd, required this.street});

  @override
  State<AddRepair> createState() => _AddRepaireState();
}

class _AddRepaireState extends State<AddRepair> {
  
  String creatorComment = '';
  List<PlatformFile> images = [];
  bool isSaving = false;
  //final picker = ImagePicker();

  Future<void> _saveRepair() async {
    if (creatorComment.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пожалуйста, заполните описание ремонта'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final storage = supabase.storage.from('pictures');
      //create repair
      final repair = await supabase.from('repairs').insert({
        'mkd_id': widget.mkd['id'],
        'status_id': 0,
        'creater_comment': creatorComment
      }).select().limit(1).single();
      print('repaire created:\n$repair');
      for (var image in images) {
        String path = DateTime.now().millisecondsSinceEpoch.toString();
        var result = await storage.uploadBinary(path, image.bytes!, fileOptions: FileOptions(upsert: true));
        print('result: $result');
        final url = supabase.storage.from('pictures').getPublicUrl(path);
        final data = await supabase.from('pictures').insert({'url': url, 'repair_id': repair['id'], 'creator_flag': 1}).select();
        print('pictures created:\n$data');
      }
      Navigator.of(context).pop(creatorComment);
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Создание планового ремонта'),
            Text(
              '${widget.street['name']}, ${widget.mkd['number']}',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (isSaving)
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _saveRepair,
              label: Text('Сохранить'),
              icon: Icon(Icons.save),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSaving ? null : () async {
          final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
          setState(() {
            if (pickedFile != null) {
              images.addAll(pickedFile.files);
            }
          });
        },
        label: Text('Добавить фото'),
        icon: Icon(Icons.add_a_photo),
        backgroundColor: isSaving ? Colors.grey : Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Информация об адресе
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue.shade700, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Адрес',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${widget.street['name']}, ${widget.mkd['number']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Поле описания
              Text(
                'Описание ремонта',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                onChanged: (value) => creatorComment = value,
                minLines: 6,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Опишите что нужно отремонтировать...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              SizedBox(height: 24),
              
              // Фотографии
              if (images.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Фотографии (${images.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: isSaving ? null : () {
                        setState(() {
                          images.clear();
                        });
                      },
                      icon: Icon(Icons.delete_outline, size: 18),
                      label: Text('Очистить'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: images.map((image) => Container(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.memory(
                          Uint8List.fromList(image.bytes!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: isSaving ? null : () {
                              setState(() {
                                images.remove(image);
                              });
                            },
                            icon: Icon(Icons.close, size: 20, color: Colors.white),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              
              if (images.isEmpty) ...[
                SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 64, color: Colors.grey.shade300),
                      SizedBox(height: 16),
                      Text(
                        'Добавьте фотографии',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Нажмите кнопку внизу экрана',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}