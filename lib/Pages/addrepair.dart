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
  //final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создание ремонта в МКД\n${widget.street['name']}, ${widget.mkd['number']}'),
        actions: [
          ElevatedButton.icon(onPressed: () async {
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
              final data = await supabase.from('pictures').insert({'url': url, 'repair_id': repair['id']}).select();
              print('pictures created:\n$data');
            }
            Navigator.of(context).pop(creatorComment);
          }, label: Text('Сохранить'), icon: Icon(Icons.save),)
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          //final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
          final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
          setState(() {
            if (pickedFile != null) {
              images.addAll(pickedFile.files);
            }
          });
        },
        label: Text('Добавить фото'),
        icon: Icon(Icons.add_a_photo),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Отчет обследования:'),
              TextField(
                onChanged: (value) => creatorComment = value,
                minLines: 5,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Развернутый коментарий'
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: images.map((image) => SizedBox(width: 200, height: 300, child: Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    Image.memory(Uint8List.fromList(image.bytes!), fit: BoxFit.cover,),
                    IconButton(onPressed: () {
                      setState(() {
                        images.remove(image);
                      });
                    }, icon: Icon(Icons.delete_forever, color: Colors.white,))
                  ]))).toList(),
              )
            ]
          ),
        ),
      ),
    );
  }
}