import 'package:flutter/material.dart';
import 'package:theory_practice/rayout/main_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        title: 'Home',
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SingleChildScrollView(),
                ));
              },
              child: Text('SingleChildScrollViewScreen'),
            )
          ],
        ));
  }
}
