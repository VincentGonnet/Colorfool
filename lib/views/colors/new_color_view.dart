import 'package:flutter/material.dart';

class NewColorView extends StatefulWidget {
  const NewColorView({Key? key}) : super(key: key);

  @override
  State<NewColorView> createState() => _NewColorViewState();
}

class _NewColorViewState extends State<NewColorView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Color"),
      ),
      body: const Text("Here"),
    );
  }
}
