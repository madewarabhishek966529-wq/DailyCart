import 'package:flutter/material.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key, required this.listId});
  final int listId;
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Shopping')));
}
