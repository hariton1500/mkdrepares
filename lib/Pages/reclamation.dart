import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mkdrepares/Widgets/all.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Reclamation extends StatefulWidget {
  final Map<String, dynamic> repair;

  const Reclamation({required this.repair, super.key});

  @override
  State<Reclamation> createState() => _ReclamationState();
}

class _ReclamationState extends State<Reclamation> {

  bool saving = false;
  TextEditingController? _controller;
  List<PlatformFile> images = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.repair['reclamation'] ?? '');
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final fpics = supabase.from('pictures').select().eq('repair_id', widget.repair['id']).eq('reclamation_flag', 1);
    return Scaffold(
      appBar: AppBar(
        title: Text('Создание / редактирование рекламации'),
        actions: [
          InkWell(
            child: saving ? Text('Идет передача данных...') : linkText('Сохранить'),
            onTap: () async {
              setState(() {
                saving = true;
              });
              await Supabase.instance.client.from('repairs').update({'reclamation': _controller?.text}).eq('id', widget.repair['id']).select().count();
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
                    'reclamation_flag': 1
                  })
                  .select().count(CountOption.exact).then((onValue){print(onValue.data);});
              }
              setState(() {
                saving = false;
              });
              Navigator.of(context).pop(_controller?.text);
            },
          ),
          SizedBox(width: 10,),
        ],
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
                  hintText: 'Комментарий к рекламации',
                  labelText: 'Рекламация'
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