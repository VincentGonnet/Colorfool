import 'package:colorfool/services/auth/auth_service.dart';
import 'package:colorfool/services/crud/colors_service.dart';
import 'package:flutter/material.dart';

class NewColorView extends StatefulWidget {
  const NewColorView({Key? key}) : super(key: key);

  @override
  State<NewColorView> createState() => _NewColorViewState();
}

class _NewColorViewState extends State<NewColorView> {
  DatabaseColor? _color;
  late final ColorsService _colorsService;
  late final TextEditingController _textController;

  Future<DatabaseColor> createNewColor() async {
    final existingColor = _color;
    if (existingColor != null) return existingColor;

    final owner = await _colorsService.getUser(
        email: AuthService.firebase().currentUser!.email!);
    return await _colorsService.createColor(owner: owner);
  }

  void _deleteColorIfTextIsEmpty() {
    final color = _color;
    if (_textController.text.isEmpty && color != null) {
      _colorsService.deleteColor(id: color.id);
    }
  }

  void _saveColorIfTextIsNotEmpty() async {
    final color = _color;
    final colorCode = _textController.text;
    if (colorCode.isNotEmpty && color != null) {
      await _colorsService.updateColor(color: color, colorCode: colorCode);
    }
  }

  void _textControllerListener() async {
    final color = _color;
    if (color == null) return;
    final colorCode = _textController.text;
    await _colorsService.updateColor(color: color, colorCode: colorCode);
  }

  void _setupTextController() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void initState() {
    _colorsService = ColorsService();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteColorIfTextIsEmpty();
    _saveColorIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("New Color"),
        ),
        body: FutureBuilder(
          future: createNewColor(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _color = snapshot.data as DatabaseColor;
                _setupTextController();
                return TextField(
                  controller: _textController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                      hintText: "Type the color code here."),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
