import 'package:flutter/material.dart';
import 'package:mkdrepares/Pages/addrepair.dart';
import 'package:mkdrepares/Pages/reclamation.dart';
import 'package:mkdrepares/Widgets/all.dart';
import 'package:mkdrepares/globals.dart';
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
  Map<String, dynamic>? actor;
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddRepair(mkd: selectedMkd, street: selectedStreet,))).then((_){
            setState(() {});
          });
        } : null,
        label: Text('Создать ремонт МКД'),
        icon: Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            spacing: 10,
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
                      decoration: BoxDecoration(color: Colors.grey, border: Border.all(width: 1.5)),
                      children: [
                        Text('Адрес:'),
                        Text('Статус:'),
                        Text('Коментарий автора:'),
                        Text('Рекламация'),
                        Text('Исполнитель'),
                        Text('Отчет')
                      ]
                    ),
                    ...showRepairs.map((repair) {
                      //load pictures
                      final fpics = Supabase.instance.client.from('pictures').select().eq('repair_id', repair['id']);
                      //load 

                      return TableRow(
                        decoration: BoxDecoration(border: Border.all(width: 0.5)),
                        children: [
                          showMkdById(repair['mkd_id']),
                          showStatusNameById(repair['status_id']),
                          Wrap(
                            children: [
                              Text(repair['creater_comment'].toString()),
                              FutureBuilder(
                                future: fpics.eq('creator_flag', 1),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return Container();
                                  final pics = snapshot.data!;
                                  return Column(
                                    children: pics.map((pic) => InkWell(
                                      onTap: () {
                                        showModalBottomSheet(context: context, builder: (context) {
                                          return Image.network('${pic['url']}', fit: BoxFit.cover,);
                                        });
                                      },
                                      child: Image.network('${pic['url']}', width: 50, height: 50, fit: BoxFit.cover,))
                                    ).toList(),
                                  );
                                }
                              )
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push<String>(MaterialPageRoute(builder: (context) => Reclamation(repair: repair))).then((rec){setState(() {repair['reclamation'] = rec;});});
                                },
                                child: Text('создать/изменить', style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic)),
                              ),
                              Text(repair['reclamation'] ?? ''),
                              FutureBuilder(
                                future: fpics.eq('reclamation_flag', 1),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return Text('');
                                  final pics = snapshot.data!;
                                  return Column(
                                    children: pics.map((pic) => InkWell(
                                      onTap: () {
                                        showModalBottomSheet(context: context, builder: (context) {
                                          return Image.network('${pic['url']}', fit: BoxFit.cover,);
                                        });
                                      },
                                      child: Image.network('${pic['url']}', width: 50, height: 50, fit: BoxFit.cover,))
                                    ).toList(),
                                  );
                                }
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Text(repair['actor'] ?? ''),
                              if (repair['actor'].toString().isEmpty) Wrap(
                                children: [
                                  activeUser['level'] == 0 ? DropdownButton(
                                    value: actor,
                                    items: users.map((user) => DropdownMenuItem(
                                      value: user,
                                      child: Text(user['login']),
                                    )).toList(),
                                    onChanged: (newUser) {
                                      setState(() {
                                        actor = newUser!;
                                      });
                                    },
                                  ) : Text(activeUser['login']),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        repair['actor'] = actor!['login'];
                                        sb.from('repairs').update({'actor': repair['actor']}).eq('id', repair['id']).select().then((onValue){print(onValue);});
                                      });
                                    },
                                    child: linkText('Назначить'),
                                  )
                                ],
                              )

                            ],
                          ),
                          Column(
                            children: [
                              Text(repair['actor_comment'] ?? ''),
                            ],
                          )
                        ]
                      );
                    })],
                  );
                },
              )
            ],
          ),
        )
      ),
    );
  }
}