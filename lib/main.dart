import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mkdrepares/Pages/error.dart';
import 'package:mkdrepares/Pages/repairs.dart';
import 'package:mkdrepares/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universal_html/html.dart' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "secrets.env");
  await Supabase.initialize(
    url: dotenv.env['url']!,
    anonKey: dotenv.env['anon']!,
  );
  //String cookies = html.document.cookie ?? "";
  //print('cookies:\n$cookies');
  try {
    final request = await html.HttpRequest.request(
      'https://billing.evpanet.com/admin/session_info.php',
      method: 'GET',
      withCredentials: true,
    );
    print('request:\n${request.responseText}');
    final data = jsonDecode(request.responseText!) as Map<String, dynamic>;
    print('decoded result:\n$data');
    activeUser = {
      'login': data['admin_login'].toString(),
      'level': int.parse(data['level']),
    };
    runApp(const MyApp());
  } catch (e) {
    print('Error:\n$e');
    runApp(const ErrorApp());
    //activeUser = {'login': 'ldos', 'level': 5};
    //runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'МКД плановые ремонты',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Repairs(),
    );
  }
}
