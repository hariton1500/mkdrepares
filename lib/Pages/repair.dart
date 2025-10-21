import 'package:flutter/material.dart';

class Repair extends StatefulWidget {
  const Repair({super.key, required this.repair});
  final Map<String, dynamic> repair;

  @override
  State<Repair> createState() => _RepairState();
}

class _RepairState extends State<Repair> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}