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
  
  @override
  Widget build(BuildContext context) {
    final fpics = supabase.from('pictures').select().eq('repair_id', widget.repair['id']).eq('${widget.name}_flag', 1);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Создание / редактирование'),
            InkWell(
              child: saving ? Text('Идет передача данных...') : linkText('Сохранить'),
              onTap: () async {
                setState(() {
                  saving = true;
                });
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
                setState(() {
                  saving = false;
                });
                Navigator.of(context).pop(_controller?.text);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            spacing: 10,
            children: [
              //Text('Коментарий:'),
              SizedBox(height: 10,),
              TextField(
                maxLines: null,
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Комментарий',
                  labelText: widget.name
                ),
              ),
              showSmallPicsFromStorage(future: fpics),
              Wrap(
                children: images.map((image) => Stack(children: [
                  Image.memory(image.bytes!, width: 100, height: 100,),
                  IconButton(onPressed: () {
                    setState(() {
                      images.remove(image);
                    });
                  }, icon: Icon(Icons.delete_forever))
                ])).toList(),
              )
            ],
          ),
        )
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
    );
  }
}