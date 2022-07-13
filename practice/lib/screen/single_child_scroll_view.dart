import 'package:flutter/material.dart';
import 'package:theory_practice/rayout/main_layout.dart';

class SingleChildScrollViewScreen extends StatelessWidget {
  const SingleChildScrollViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        title: 'SingleChildScroolView',
        body: Container(
          child: Text('Hello'),
        ));
  }
}
