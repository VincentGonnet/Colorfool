import 'package:colorfool/services/auth/auth_service.dart';
import 'package:colorfool/services/crud/colors_service.dart';
import 'package:colorfool/utilities/dialogs/error_dialog.dart';
import 'package:colorfool/utilities/generics/get_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateUpdateColorView extends StatefulWidget {
  const CreateUpdateColorView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateColorView> createState() => _CreateUpdateColorViewState();
}

class _CreateUpdateColorViewState extends State<CreateUpdateColorView> {
  DatabaseColor? _color;
  Color _rawColor = Colors.blue;
  bool hasBeenSaved = false;
  late final ColorsService _colorsService;
  late final TextEditingController _textController;

  Future<DatabaseColor> _createOrGetColor() async {
    final widgetColor = context.getArgument<DatabaseColor>();
    if (widgetColor != null) {
      _color = widgetColor;
      _textController.text = widgetColor.colorCode;
      _rawColor = _getColorFromFormattedCode(widgetColor.colorCode);
      hasBeenSaved = true;
      return widgetColor;
    }

    final existingColor = _color;
    if (existingColor != null) return existingColor;

    final owner = await _colorsService.getUser(
        email: AuthService.firebase().currentUser!.email!);
    final newColor = await _colorsService.createColor(owner: owner);
    _color = newColor;
    return newColor;
  }

  void _deleteColorIfNotSaved() {
    final color = _color;
    if (color != null && !hasBeenSaved) {
      _colorsService.deleteColor(id: color.id);
    }
  }

  void _saveColorAndExit() async {
    final color = _color;
    final colorCode = _textController.text;
    if (color != null && _textInputValidation(colorCode)) {
      await _colorsService.updateColor(color: color, colorCode: colorCode);
      hasBeenSaved = true;
    } else {
      showErrorDialog(context, "Invalid color format");
    }
  }

  bool _textInputValidation(String input) {
    final RegExp hex = RegExp(r'([a-f0-9]{6})');
    return hex.hasMatch(input);
  }

  void _textControllerListener() async {
    final colorCode = _textController.text;
    if (!_textInputValidation(colorCode)) {
      // TODO: tell the user the input is not correct
    }
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
    _deleteColorIfNotSaved();
    _textController.dispose();
    super.dispose();
  }

  String _getFormattedColorCode(Color color) {
    return color.value.toRadixString(16).substring(2);
  }

  Color _getColorFromFormattedCode(String colorCode) {
    return Color(int.parse('ff$colorCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ColorfoolAppBar(controller: _textController),
        body: FutureBuilder(
          future: _createOrGetColor(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _setupTextController();
                return Column(children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: "Color code",
                            hintMaxLines: 1,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Pick a color !"),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: _rawColor,
                                        onColorChanged: (Color color) {
                                          _rawColor = color;
                                        },
                                      ),
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          _textController.text =
                                              _getFormattedColorCode(_rawColor);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Done"),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: const Text("Default Color Picker"),
                        )
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                      onPressed: () {
                        _saveColorAndExit();
                      },
                      child: const Text("Done"),
                    ),
                  )
                ]);
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}

class ColorfoolAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ColorfoolAppBar({Key? key, required this.controller})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  final TextEditingController controller;

  @override
  State<ColorfoolAppBar> createState() => _ColorfoolAppBarState();
}

class _ColorfoolAppBarState extends State<ColorfoolAppBar> {
  Color _color = Colors.blue;
  final RegExp hex = RegExp(r'([a-f0-9]{6})');

  void _setColor(String colorCode) {
    if (hex.hasMatch(colorCode)) {
      _color = Color(int.parse('ff$colorCode', radix: 16));
    }
  }

  @override
  void initState() {
    _setColor(widget.controller.text);
    widget.controller.addListener(() {
      final colorCode = widget.controller.text;
      setState(() {
        _setColor(colorCode);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("New color"),
      backgroundColor: _color,
    );
  }
}
