import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget showStatusNameById(int id) {
  final _fStatus = Supabase.instance.client.from('status').select().eq('id', id);
  return FutureBuilder(future: _fStatus, builder: (context, snapshot) {
    if (!snapshot.hasData) {return Container();}
    final result = snapshot.data!;
    return Row(
      children: result.map((res) => Text(res['name'])).toList(),
    );
  });
}

Widget showMkdById(int id) {
  final fMkd = Supabase.instance.client.from('mkd').select().eq('id', id);
  return FutureBuilder(
    future: fMkd,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {return Container();}
      final mkds = snapshot.data!;
      final fStreet = Supabase.instance.client.from('streets').select().eq('id', mkds.first['street_id']);
      return Row(
        children: [
          FutureBuilder(
            future: fStreet,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {return Container();}
              final streets = snapshot.data!;
              return Text('${streets.first['name']}, ');
            }
          ),
          Text(mkds.first['number'])
        ],
      );
    },
  );
}

Widget linkText(String text) {
  return Text(text, style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic));
}