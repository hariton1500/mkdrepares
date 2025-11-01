// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mkdrepares/Pages/addrepair.dart';
import 'package:mkdrepares/Pages/editrep.dart';
import 'package:mkdrepares/Widgets/all.dart';
import 'package:mkdrepares/globals.dart';
import 'package:mkdrepares/mkds.dart';
import 'package:mkdrepares/streets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class Repairs extends StatefulWidget {
  const Repairs({super.key});

  @override
  State<Repairs> createState() => _RepairsState();
}

class _RepairsState extends State<Repairs> {
  //final _futureStreets = Supabase.instance.client.from('streets').select();

  Map<String, dynamic> selectedStreet = {};
  Map<String, dynamic> selectedMkd = {};
  Map<int, String> selectedStatus = {}; //int - repair id
  Map<String, dynamic>? actor = activeUser;
  var sb = Supabase.instance.client;
  //late PostgrestFilterBuilder<List<Map<String, dynamic>>> _fMkd;

  int showStatus = -1;
  late PostgrestFilterBuilder<List<Map<String, dynamic>>> repairs;
  //final _fStatuses = Supabase.instance.client.from('status').select();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('$selectedStreet, $selectedMkd');
    return Scaffold(
      appBar: AppBar(
        title: Text('Плановые ремонты МКД'),
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  DropdownButton<Map<String, dynamic>>(
                    value: selectedStreet.isEmpty ? null : selectedStreet,
                    hint: Text('Выбор улицы'),
                    items:
                        streets
                            .map(
                              (street) =>
                                  DropdownMenuItem<Map<String, dynamic>>(
                                    value: street,
                                    child: Text(street['name']),
                                  ),
                            )
                            .toList(),
                    onChanged: (e) {
                      setState(() {
                        selectedMkd = {};
                        selectedStreet = e!;
                      });
                    }
                  ),
                  /*
                  FutureBuilder(
                    future: _futureStreets,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final streets = snapshot.data!;
                      return DropdownButton<Map<String, dynamic>>(
                        value: selectedStreet.isEmpty ? null : selectedStreet,
                        hint: Text('Выбор улицы'),
                        items:
                            streets
                                .map(
                                  (street) =>
                                      DropdownMenuItem<Map<String, dynamic>>(
                                        value: street,
                                        child: Text(street['name']),
                                      ),
                                )
                                .toList(),
                        onChanged: (e) {
                          setState(() {
                            selectedMkd = {};
                            selectedStreet = e!;
                          });
                          _fMkd = sb
                              .from('mkd')
                              .select()
                              .eq('street_id', selectedStreet['id']);
                        },
                      );
                    },
                  ),*/
                  if (selectedStreet.isNotEmpty)
                    DropdownButton<Map<String, dynamic>>(
                      value: selectedMkd.isEmpty ? null : selectedMkd,
                      hint: Text('Выбор дома'),
                      items:
                          mkds.where((mkd) => mkd['street_id'] == selectedStreet['id'])
                              .map(
                                (mkd) =>
                                    DropdownMenuItem<Map<String, dynamic>>(
                                      value: mkd,
                                      child: Text(mkd['number']),
                                    ),
                              )
                              .toList(),
                      onChanged: (e) {
                        setState(() {
                          selectedMkd = e!;
                        });
                      },
                    )
                    /*
                    FutureBuilder(
                      future: _fMkd,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: Text('Выбор дома'));
                        }
                        final mkds = snapshot.data!;
                        return DropdownButton<Map<String, dynamic>>(
                          value: selectedMkd.isEmpty ? null : selectedMkd,
                          hint: Text('Выбор дома'),
                          items:
                              mkds
                                  .map(
                                    (mkd) =>
                                        DropdownMenuItem<Map<String, dynamic>>(
                                          value: mkd,
                                          child: Text(mkd['number']),
                                        ),
                                  )
                                  .toList(),
                          onChanged: (e) {
                            setState(() {
                              //selectedMkd = {};
                              selectedMkd = e!;
                            });
                          },
                        );
                      },
                    ),*/
                ],
              ),
              if (selectedStreet.isNotEmpty && selectedMkd.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder:
                                  (context) => AddRepair(
                                    mkd: selectedMkd,
                                    street: selectedStreet,
                                  ),
                            ),
                          )
                          .then((onValue) {
                            if (onValue != null) {
                              setState(() {
                                repairs = sb
                                    .from('repairs')
                                    .select()
                                    .eq('status_id', showStatus);
                              });
                            }
                          });
                    },
                    icon: Icon(Icons.add),
                    label: Text('Создать плановый ремонт'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              // Секция фильтров
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.grey.shade700, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Фильтры',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...statuses.asMap().entries.map(
                          (entry) {
                            int index = entry.key;
                            String status = entry.value;
                            bool isSelected = showStatus == index;
                            return FilterChip(
                              label: Text(status),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  showStatus = selected ? index : -1;
                                  if (selected) {
                                    repairs = sb
                                        .from('repairs')
                                        .select()
                                        .eq('status_id', showStatus);
                                  }
                                });
                              },
                              selectedColor: statusColors[index],
                              backgroundColor: Colors.white,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                width: 1,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            );
                          },
                        ),
                        if (selectedStreet.isNotEmpty && selectedMkd.isNotEmpty)
                          FilterChip(
                            avatar: Icon(Icons.location_on, size: 16),
                            label: Text('По адресу'),
                            selected: showStatus == 5,
                            onSelected: (selected) {
                              setState(() {
                                showStatus = selected ? 5 : -1;
                                if (selected) {
                                  repairs = sb
                                      .from('repairs')
                                      .select()
                                      .eq('mkd_id', selectedMkd['id']);
                                }
                              });
                            },
                            selectedColor: Colors.blue.shade300,
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              fontWeight: showStatus == 5 ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            side: BorderSide(
                              color: showStatus == 5 ? Colors.transparent : Colors.grey.shade300,
                              width: 1,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Список ремонтов
              if (showStatus >= 0)
                FutureBuilder(
                  future: repairs,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    var showRepairs = snapshot.data!;
                    for (var repair in showRepairs) {
                      if (repair['ddactor'].toString().isEmpty) {
                        repair['ddactor'] = activeUser['login'];
                      }
                    }
                    if (showRepairs.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text(
                              'Нет ремонтов',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Выберите другой фильтр или создайте новый ремонт',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      spacing: 12,
                      children:
                          showRepairs.map((repair) {
                            final fpics = sb
                                .from('pictures')
                                .select()
                                .eq('repair_id', repair['id']);
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.bottomStart,
                                children: [
                                  ListTile(
                                    dense: true,
                                    isThreeLine: true,
                                    leading: SizedBox(
                                      child: Column(
                                        spacing: 5,
                                        children: [
                                          Text(
                                            ' ${statuses[repair['status_id']]}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              backgroundColor:
                                                  statusColors[repair['status_id']],
                                            ),
                                          ),
                                          if (repair['actor']
                                                  .toString()
                                                  .isEmpty &&
                                              activeUser['level'] > 5)
                                            InkWell(
                                              child: linkText(
                                                '[Назначить себе]',
                                              ),
                                              onTap: () async {
                                                await sb
                                                    .from('repairs')
                                                    .update({
                                                      'actor':
                                                          activeUser['login'],
                                                    })
                                                    .eq('id', repair['id'])
                                                    .limit(1)
                                                    .select();
                                                setState(() {
                                                  repair['actor'] =
                                                      activeUser['login'];
                                                  repairs = sb
                                                      .from('repairs')
                                                      .select()
                                                      .eq(
                                                        'status_id',
                                                        showStatus,
                                                      );
                                                });
                                              },
                                            ),
                                          if (repair['actor']
                                                  .toString()
                                                  .isEmpty &&
                                              activeUser['level'] <= 5)
                                            InkWell(
                                              child: linkText(
                                                '[Назначить исполнителя]',
                                              ),
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder:
                                                      (context) => Scaffold(
                                                        body: SingleChildScrollView(
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                'Выберите исполнителя:',
                                                              ),
                                                              ...users.map(
                                                                (
                                                                  user,
                                                                ) => InkWell(
                                                                  child:
                                                                      linkText(
                                                                        user,
                                                                      ),
                                                                  onTap: () async {
                                                                    await sb
                                                                        .from(
                                                                          'repairs',
                                                                        )
                                                                        .update({
                                                                          'actor':
                                                                              user,
                                                                        })
                                                                        .eq(
                                                                          'id',
                                                                          repair['id'],
                                                                        )
                                                                        .limit(
                                                                          1,
                                                                        )
                                                                        .select();
                                                                    setState(() {
                                                                      repair['actor'] =
                                                                          user;
                                                                      repairs = sb
                                                                          .from(
                                                                            'repairs',
                                                                          )
                                                                          .select()
                                                                          .eq(
                                                                            'status_id',
                                                                            showStatus,
                                                                          );
                                                                    });
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(user);
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                ).then((onValue) {
                                                  if (onValue != null) {
                                                    print(onValue);
                                                  }
                                                });
                                              },
                                            ),
                                          if (repair['actor']
                                              .toString()
                                              .isNotEmpty)
                                            activeUser['level'] <= 5
                                                ? InkWell(
                                                  child: linkText(
                                                    '[${repair['actor']}]',
                                                  ),
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder:
                                                          (context) => Scaffold(
                                                            body: SingleChildScrollView(
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    'Выберите исполнителя:',
                                                                  ),
                                                                  ...users.map(
                                                                    (
                                                                      user,
                                                                    ) => InkWell(
                                                                      child:
                                                                          linkText(
                                                                            user,
                                                                          ),
                                                                      onTap: () async {
                                                                        await sb
                                                                            .from(
                                                                              'repairs',
                                                                            )
                                                                            .update({
                                                                              'actor':
                                                                                  user,
                                                                            })
                                                                            .eq(
                                                                              'id',
                                                                              repair['id'],
                                                                            )
                                                                            .limit(
                                                                              1,
                                                                            )
                                                                            .select();
                                                                        setState(() {
                                                                          repair['actor'] =
                                                                              user;
                                                                          repairs = sb
                                                                              .from(
                                                                                'repairs',
                                                                              )
                                                                              .select()
                                                                              .eq(
                                                                                'status_id',
                                                                                showStatus,
                                                                              );
                                                                        });
                                                                        Navigator.of(
                                                                          context,
                                                                        ).pop(
                                                                          user,
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                    ).then((onValue) {
                                                      if (onValue != null) {
                                                        print(onValue);
                                                      }
                                                    });
                                                  },
                                                )
                                                : Text('[${repair['actor']}]'),
                                        ],
                                      ),
                                    ),
                                    title: Wrap(
                                      alignment: WrapAlignment.start,
                                      spacing: 10,
                                      runSpacing: 5,
                                      children: [
                                        showMkdById(repair['mkd_id']),
                                        if (activeUser['level'] <= 5)
                                          InkWell(
                                            child: linkText('[Рекламация]'),
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (context) => EditRep(
                                                      repair: repair,
                                                      name: 'reclamation',
                                                    ),
                                              ).then((onValue) {
                                                setState(() {
                                                  repairs = sb
                                                      .from('repairs')
                                                      .select()
                                                      .eq(
                                                        'status_id',
                                                        showStatus,
                                                      );
                                                });
                                              });
                                            },
                                          ),
                                        if (activeUser['level'] <= 5 ||
                                            activeUser['login'] ==
                                                repair['actor'])
                                          InkWell(
                                            child: linkText('[Отчет]'),
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (context) => EditRep(
                                                      repair: repair,
                                                      name: 'report',
                                                    ),
                                              ).then((onValue) {
                                                setState(() {
                                                  repairs = sb
                                                      .from('repairs')
                                                      .select()
                                                      .eq(
                                                        'status_id',
                                                        showStatus,
                                                      );
                                                });
                                              });
                                            },
                                          ),
                                        if (activeUser['level'] <= 5)
                                          InkWell(
                                            child: linkText('[Статус]'),
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (context) => Scaffold(
                                                      body: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              40.0,
                                                            ),
                                                        child: Column(
                                                          spacing: 10,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          //mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              'Выберите статус:',
                                                            ),
                                                            ...statuses.map(
                                                              (
                                                                status,
                                                              ) => InkWell(
                                                                child: linkText(
                                                                  status,
                                                                ),
                                                                onTap: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(status);
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                              ).then((onValue) async {
                                                print(onValue);
                                                if (onValue != null) {
                                                  await sb
                                                      .from('repairs')
                                                      .update({
                                                        'status_id': statuses
                                                            .indexOf(onValue),
                                                      })
                                                      .eq('id', repair['id'])
                                                      .limit(1)
                                                      .select();
                                                  setState(() {
                                                    repairs = sb
                                                        .from('repairs')
                                                        .select()
                                                        .eq(
                                                          'status_id',
                                                          showStatus,
                                                        );
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          child: Text(
                                            'Входные данные: ${repair['creater_comment']}',
                                            maxLines: 1,
                                          ),
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder:
                                                  (context) => Scaffold(
                                                    body: Text(
                                                      repair['creater_comment']
                                                          .toString(),
                                                    ),
                                                  ),
                                            );
                                          },
                                        ),
                                        showPics(fpics.eq('creator_flag', 1)),
                                        Divider(),
                                        InkWell(
                                          child: Text(
                                            'Рекламация: ${repair['reclamation']}',
                                            maxLines: 1,
                                          ),
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder:
                                                  (context) => Scaffold(
                                                    body: Text(
                                                      repair['creater_comment']
                                                          .toString(),
                                                    ),
                                                  ),
                                            );
                                          },
                                        ),
                                        showPics(fpics.eq('reclamation_flag', 1)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      DateFormat('dd.MM.yyyy')
                                          .format(
                                            DateTime.parse(
                                              repair['created_at'],
                                            ),
                                          )
                                          .toString(),
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  },
                ),
              /*
              if (showStatus >= 0) FutureBuilder(
                future: repairs,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  var showRepairs = snapshot.data!;
                  //for dropdown filling ddactors with active user login
                  for (var repair in showRepairs) {
                    if (repair['ddactor'].toString().isEmpty) repair['ddactor'] = activeUser['login'];
                    //selectedStatus[repair['id']] = statuses[repair['status_id']];
                  }///////////
                  //final fStatuses = sb.from('status').select();
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
                      final fpics = sb.from('pictures').select().eq('repair_id', repair['id']);
                      //load
                      return TableRow(
                        decoration: BoxDecoration(border: Border.all(width: 0.5)),
                        children: [
                          showMkdById(repair['mkd_id']),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //showStatusNameById(repair['status_id']),
                              Text(statuses[repair['status_id']]),
                              if (activeUser['level'] == 0) DropdownButton(
                                value: selectedStatus[repair['id']] ?? statuses[0],
                                items: statuses.map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                )).toList(),
                                onChanged: (newStatus) {
                                  print('new selected status on repair ${repair['id']} is $newStatus');
                                  setState(() {
                                    //repair['status_id'] = statuses.indexOf(newStatus!);
                                    selectedStatus[repair['id']] = newStatus!;
                                  });
                                }
                              ),
                              if (activeUser['level'] == 0) InkWell(
                                child: linkText('Установить'),
                                onTap: () async {
                                  repair['status_id'] = statuses.indexOf(selectedStatus[repair['id']]!);
                                  await sb.from('repairs').update({'status_id': repair['status_id']}).eq('id', repair['id']);
                                  //showStatus = repair['status_id'];
                                  repairs = sb.from('repairs').select().eq('status_id', showStatus);
                                  setState(() {
                                    
                                  });
                                },
                              )
                            ],
                          ),
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
                          Wrap(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push<String>(MaterialPageRoute(builder: (context) => EditRep(repair: repair, name: 'reclamation',))).then((rec){setState(() {repair['reclamation'] = rec;});});
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
                                  activeUser['level'] == 0 ? DropdownButton<String>(
                                    value: repair['ddactor'],
                                    items: users.map((user) => DropdownMenuItem<String>(
                                      value: user,
                                      child: Text(user),
                                    )).toList(),
                                    onChanged: (newUser) {
                                      setState(() {
                                        //print('before: ${repair['ddactor']}');
                                        repair['ddactor'] = newUser!;
                                        //print('after: ${repair['ddactor']}');
                                      });
                                    },
                                  ) : Text(activeUser['login']),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        repair['actor'] = activeUser['level'] == 0 ? repair['ddactor'] : activeUser['login'];
                                        sb.from('repairs').update({'actor': repair['actor']}).eq('id', repair['id']).select().then((onValue){print(onValue);});
                                      });
                                    },
                                    child: linkText('Назначить'),
                                  )
                                ],
                              )

                            ],
                          ),
                          //report
                          Wrap(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push<String>(MaterialPageRoute(builder: (context) => EditRep(repair: repair, name: 'report',))).then((rec){setState(() {repair['reclamation'] = rec;});});
                                },
                                child: Text('создать/изменить', style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic)),
                              ),
                              Text(repair['report'] ?? ''),
                              FutureBuilder(
                                future: fpics.eq('report_flag', 1),
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
                        ]
                      );
                    })],
                  );
                },
              )*/
            ],
          ),
        ),
      ),
    );
  }
}
