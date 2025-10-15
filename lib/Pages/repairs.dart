import 'package:flutter/material.dart';
import 'package:mkdrepares/Pages/addrepaire.dart';

class Repairs extends StatefulWidget {
  const Repairs({super.key});

  @override
  State<Repairs> createState() => _RepairsState();
}

class _RepairsState extends State<Repairs> {
  
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
            Row()
          ],
        )
      ),
    );
  }
}