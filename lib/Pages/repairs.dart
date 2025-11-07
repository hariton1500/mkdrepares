// ignore_for_file: use_build_context_synchronously

import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:mkdrepares/Pages/addrepair.dart';
import 'package:mkdrepares/Pages/repair.dart';
import 'package:mkdrepares/globals.dart';
import 'package:mkdrepares/mkds.dart';
import 'package:mkdrepares/streets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Repairs extends StatefulWidget {
  const Repairs({super.key});

  @override
  State<Repairs> createState() => _RepairsState();
}

class _RepairsState extends State<Repairs> {

  Map<String, dynamic> selectedStreet = {};
  Map<String, dynamic> selectedMkd = {};
  Map<int, String> selectedStatus = {}; //int - repair id
  Map<String, dynamic>? actor = activeUser;
  var sb = Supabase.instance.client;
  
  int showStatus = -1;
  late PostgrestFilterBuilder<List<Map<String, dynamic>>> repairs;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Выберите улицу:'),
                  DropDownSearchField(
                    //initiallySelectedItems: [selectedStreet],
                    displayAllSuggestionWhenTap: true,
                    isMultiSelectDropdown: false,
                    textFieldConfiguration: TextFieldConfiguration(
                      autofocus: false,
                      //style: DefaultTextStyle.of(context).style.copyWith(fontStyle: FontStyle.italic),
                      decoration: InputDecoration(
                        border: OutlineInputBorder()
                      )
                    ),
                    suggestionsCallback: (pattern) async {
                      return streets.where((street) => street['name'].toString().startsWith(pattern));
                    },
                    itemBuilder: (context, suggestion) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(suggestion['name']),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        selectedMkd = {};
                        selectedStreet = suggestion;
                      });
                    },
                  ),
                  if (selectedStreet.isNotEmpty)
                    Row(
                      spacing: 20,
                      children: [
                        Chip(label: Text('${selectedStreet['name']}  ')),
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
                            setState(() {selectedMkd = e!;});
                          },
                        ),
                      ],
                    ),
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
                      children: showRepairs.map((repair) {
                        final fpics = sb
                            .from('pictures')
                            .select()
                            .eq('repair_id', repair['id']);
                        return RepairCard(
                          repair: repair,
                          fpics: fpics,
                          showStatus: showStatus,
                          onUpdate: () {
                            setState(() {
                              repairs = sb
                                  .from('repairs')
                                  .select()
                                  .eq('status_id', showStatus);
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
