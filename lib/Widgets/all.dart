import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget showStatusNameById(int id) {
  final fStatus = Supabase.instance.client.from('status').select().eq('id', id).limit(1).single();
  return FutureBuilder(future: fStatus, builder: (context, snapshot) {
    if (!snapshot.hasData) return Text('');
    final result = snapshot.data!;
    return Text(result['name']);
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
              if (!snapshot.hasData) return Container();
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

Widget showSmallPicsFromStorage({required Future<List<Map<String, dynamic>>>? future}) {
  return FutureBuilder(
    future: future,
    builder: (context, snapshot) {
      if (!snapshot.hasData) return Text('');
      final data = snapshot.data!;
      return Wrap(
        spacing: 10,
        children: data.map((pic) => Image.network('${pic['url']}', width: 100, height: 100, fit: BoxFit.cover,)).toList(),
      );
    }
  );

}
