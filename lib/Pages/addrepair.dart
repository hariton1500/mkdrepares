import 'package:flutter/material.dart';

class AddRepair extends StatefulWidget {
  final Map<String, dynamic> mkd;
  final Map<String, dynamic> street;

  const AddRepair({super.key, required this.mkd, required this.street});

  @override
  State<AddRepair> createState() => _AddRepaireState();
}

class _AddRepaireState extends State<AddRepair> {
  
  String creatorComment = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создание ремонта в МКД\n${widget.street['name']}, ${widget.mkd['number']}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text('Отчет обследования:'),
            TextField(
              onChanged: (value) => creatorComment = value,
              minLines: 5,
              
            ),
            
          ]
        ),
      ),
    );
  }
}