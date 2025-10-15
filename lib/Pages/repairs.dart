import 'package:flutter/material.dart';
import 'package:mkdrepares/Pages/addrepaire.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Repairs extends StatefulWidget {
  const Repairs({super.key});

  @override
  State<Repairs> createState() => _RepairsState();
}

class _RepairsState extends State<Repairs> {
  
  final _futureStreets = Supabase.instance.client
    .from('streets')
    .select();
  
  Map<String, dynamic> selectedStreet = {};

  PostgrestFilterBuilder<List<Map<String, dynamic>>> futureMkd = Supabase.instance.client.from('mkd').select();

  Map<String, dynamic> selectedMkd = {};

  @override
  void initState() {
    _futureStreets.then((e){print(e);});
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ремонты:'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddRepaire()));
      }),
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
                          selectedStreet = e!;
                          //futureMkd = futureMkd.filter('street_id', 'eq', e['id']);
                        });
                      }
                    );
                  }
                ),
                FutureBuilder(
                  future: futureMkd.filter('street_id', 'eq', selectedStreet['id']),
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
                          selectedMkd = e!;
                        });
                      }
                    );
                  }
                )
              ],
            )
          ],
        )
      ),
    );
  }
}