import 'package:flutter/material.dart';
import 'package:mkdrepares/Pages/repairs.dart';
import 'package:mkdrepares/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "secrets.env");
  await Supabase.initialize(
    url: dotenv.env['url']!,
    anonKey: dotenv.env['anon']!,
  );
  runApp(const MyApp());
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
      home: const MyHomePage(title: 'МКД плановые ремонты'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String login = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Авторизация:'),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: TextField(
                onChanged: (value) => login = value,
                //style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ElevatedButton(onPressed: () {
              if (users.any((user) => user['login'] == login)) {
                activeUser = users.firstWhere((u) => u['login'] == login);
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Repairs()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Такой оператор не зарегистрирован',
                    ),
                    duration: Duration(milliseconds: 4000),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }, child: Text('Войти'))
          ],
        ),
      ),
    );
  }
}
