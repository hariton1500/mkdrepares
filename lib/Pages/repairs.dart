import 'package:flutter/material.dart';
import 'package:mkdrepares/Pages/addrepair.dart';
import 'package:mkdrepares/Widgets/all.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Repairs extends StatefulWidget {
  const Repairs({super.key});

  @override
  State<Repairs> createState() => _RepairsState();
}

class _RepairsState extends State<Repairs> {
  
  final _futureStreets = Supabase.instance.client.from('streets').select();
  
  Map<String, dynamic> selectedStreet = {};
  Map<String, dynamic> selectedMkd = {};
  var sb = Supabase.instance.client;
  late PostgrestFilterBuilder<List<Map<String, dynamic>>> _fMkd;

  int showStatus = -1;
  late PostgrestFilterBuilder<List<Map<String, dynamic>>> repairs;
  final _fStatuses = Supabase.instance.client.from('status').select();

  @override
  void initState() {
    //_futureStreets = sb.from('streets').select();
    //futureMkd.then((f) => mkds = f);
    //repairs = sb.from('repairs').select().eq('status_id', showStatus);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ремонты:'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedStreet.isNotEmpty && selectedMkd.isNotEmpty ? () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddRepair(mkd: selectedMkd, street: selectedStreet,)));
        } : null,
        label: Text('Создать ремонт МКД'),
        icon: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                FutureBuilder(
                  future: _futureStreets,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final streets = snapshot.data!;
                    return DropdownButton<Map<String, dynamic>>(
                      value: selectedStreet.isEmpty ? null : selectedStreet,
                      hint: Text('Выбор улицы'),
                      items: streets.map((street) => DropdownMenuItem<Map<String, dynamic>>(
                        value: street,
                        child: Text(street['name'])
                      )).toList(),
                      onChanged: (e) {
                        setState(() {
                          selectedMkd = {};
                          selectedStreet = e!;
                        });
                        _fMkd = sb.from('mkd').select().eq('street_id', selectedStreet['id']);
                      }
                    );
                  }
                ),
                
                if (selectedStreet.isNotEmpty)
                FutureBuilder(
                  future: _fMkd,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('Выбор дома'),
                      );
                    }
                    final mkds = snapshot.data!;
                    //print('after setstate mkds:\n$mkds');

                    return DropdownButton<Map<String, dynamic>>(
                      value: selectedMkd.isEmpty ? null : selectedMkd,
                      hint: Text('Выбор дома'),
                      items: mkds.map((mkd) => DropdownMenuItem<Map<String, dynamic>>(
                        value: mkd,
                        child: Text(mkd['number'])
                      )).toList(),
                      onChanged: (e) {
                        setState(() {
                          //selectedMkd = {};
                          selectedMkd = e!;
                        });
                      }
                    );
                  }
                ),
              ],
            ),
            FutureBuilder(
              future: _fStatuses,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                final statuses = snapshot.data!;
                return Wrap(
                  spacing: 10,
                  children: statuses.map((status) => InkWell(
                    onTap: () {
                      setState(() {
                        showStatus = status['id'];
                        print('new showStatus: $showStatus');
                        repairs = sb.from('repairs').select().eq('status_id', showStatus);
                      });
                    },
                    child: Text(status['name']),
                  )).toList(),
                );
              }
            ),
            if (showStatus > 0) FutureBuilder(
              future: repairs,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                final showRepairs = snapshot.data!;
                return Table(
                  children: [TableRow(
                    children: [
                      Text('Адрес:'),
                      Text('Статус:'),
                      Text('Коментарий автора:'),
                    ]
                  ),
                  ...showRepairs.map((repair) {
                    final _fpics = Supabase.instance.client.from('pictures').select().eq('repair_id', repair['id']);
                    return TableRow(
                      children: [
                        showMkdById(repair['mkd_id']),
                        showStatusNameById(repair['status_id']),
                        Wrap(
                          children: [
                            Text(repair['creater_comment'].toString()),
                            FutureBuilder(
                              future: _fpics,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Container();
                                final pics = snapshot.data!;
                                final fImage = Supabase.instance.client.storage.from('pictures').url;
                                return Column(
                                  children: pics.map((pic) => Image.network('https://fhwzycuydrlxglwfzoku.supabase.co/storage/v1/object/sign/pictures/${pic['url']}?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV80ZmY0YmU0Yy1iYWQ3LTQ4YWMtOWRkZS02MmFhYjc4MGJkODIiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwaWN0dXJlcy8xNzYwNjUzMTQ1MDk4IiwiaWF0IjoxNzYwNjkyNDY3LCJleHAiOjE3OTIyMjg0Njd9.i7oQTGG7mKpwjFi8Ae9xc8BYw-mq0O6oVAXE0i8SsRE')).toList(),
                                );
                              }
                            )
                          ],
                        )
                      ]
                    );
                  }).toList()],
                );
              },
            )
          ],
        )
      ),
    );
  }
}