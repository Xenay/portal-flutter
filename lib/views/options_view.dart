import 'package:flutter/material.dart';

class OptionsView extends StatelessWidget {
  const OptionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Options'),
      ),
      body: Center(
        child: Text(
          'Options Page (Proof of Concept)',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
