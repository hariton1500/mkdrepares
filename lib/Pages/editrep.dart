import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mkdrepares/Widgets/all.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditRep extends StatefulWidget {
  final Map<String, dynamic> repair;
  final String name;

  const EditRep({required this.repair, required this.name, super.key});

  @override
  State<EditRep> createState() => _ReclamationState();
}

class _ReclamationState extends State<EditRep> {

  bool saving = false;
  TextEditingController? _controller;
  List<PlatformFile> images = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.repair[widget.name] ?? '');
    super.initState();
  }

  String _getTitle() {
    switch (widget.name) {
      case 'reclamation':
        return 'Рекламация';
      case 'report':
        return 'Отчет о выполнении';
      default:
        return 'Редактирование';
    }
  }

  Future<void> _saveData() async {
    setState(() {
      saving = true;
    });

    try {
      await supabase.from('repairs').update({widget.name: _controller?.text}).eq('id', widget.repair['id']).select().count();
      
      for (var image in images) {
        final path = DateTime.now().microsecondsSinceEpoch.toString();
        print('uploading images...');
        await supabase.storage.from('pictures')
          .uploadBinary(path, image.bytes!, fileOptions: FileOptions(upsert: true)).then((onValue){print(onValue);});
        print('inserting picture info...');
        await supabase.from('pictures')
          .insert({
            'url': supabase.storage.from('pictures').getPublicUrl(path),
            'repair_id': widget.repair['id'],
            '${widget.name}_flag': 1
          })
          .select().count(CountOption.exact).then((onValue){print(onValue.data);});
      }
      Navigator.of(context).pop(_controller?.text);
    } catch (e) {
      setState(() {
        saving = false;
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
    final fpics = supabase.from('pictures').select().eq('repair_id', widget.repair['id']).eq('${widget.name}_flag', 1);
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (saving)
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
              onPressed: _saveData,
              label: Text('Сохранить'),
              icon: Icon(Icons.save),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Text(
                _getTitle(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.name == 'reclamation' 
                    ? 'Опишите проблему или замечание к ремонту'
                    : 'Опишите выполненную работу и результаты ремонта',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 24),
              
              // Поле ввода
              TextField(
                maxLines: null,
                minLines: 6,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.name == 'reclamation'
                      ? 'Опишите проблему...'
                      : 'Опишите выполненную работу...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              SizedBox(height: 24),
              
              // Существующие фотографии
              FutureBuilder(
                future: fpics,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox.shrink();
                  final existingPics = snapshot.data!;
                  if (existingPics.isEmpty) return SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Текущие фотографии (${existingPics.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      showSmallPicsFromStorage(future: fpics),
                      SizedBox(height: 24),
                    ],
                  );
                },
              ),
              
              // Новые фотографии
              if (images.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Новые фотографии (${images.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: saving ? null : () {
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
                            image.bytes!,
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
                              onPressed: saving ? null : () {
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
                SizedBox(height: 24),
              ],
              
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
        )
      ),
      floatingActionButton: saving ? null : FloatingActionButton.extended(
        onPressed: () async {
          final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
          setState(() {
            if (pickedFile != null) {
              images.addAll(pickedFile.files);
            }
          });
        },
        label: Text('Добавить фото'),
        icon: Icon(Icons.add_a_photo),
        backgroundColor: Colors.blue,
      ),
    );
  }
}