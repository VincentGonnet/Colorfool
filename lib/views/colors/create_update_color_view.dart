import 'package:colorfool/services/auth/auth_service.dart';
import 'package:colorfool/services/crud/colors_service.dart';
import 'package:colorfool/utilities/dialogs/error_dialog.dart';
import 'package:colorfool/utilities/generics/get_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:colorfool/utilities/conversions/color_code.dart';

enum PickerType { precise, material, block }

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
  final ValueNotifier<PickerType> _pickerType =
      ValueNotifier(PickerType.precise);
  final ValueNotifier<bool> _validTextInput = ValueNotifier(false);

  Future<DatabaseColor> _createOrGetColor() async {
    final widgetColor = context.getArgument<DatabaseColor>();
    if (widgetColor != null) {
      _color = widgetColor;
      _textController.text = widgetColor.colorCode;
      _rawColor = getColorFromFormattedCode(widgetColor.colorCode);
      hasBeenSaved = true;
      _validTextInput.value = hasBeenSaved;
      return widgetColor;
    }

    final existingColor = _color;
    if (existingColor != null) return existingColor;

    final owner = await _colorsService.getUser(
        email: AuthService.firebase().currentUser!.email);
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
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      showErrorDialog(context, "Invalid color format");
    }
  }

  bool _textInputValidation(String input) {
    final RegExp hex = RegExp(r'([a-fA-F0-9]{6})');
    return hex.hasMatch(input);
  }

  void _textControllerListener() async {
    final colorCode = _textController.text;
    _validTextInput.value = _textInputValidation(colorCode);
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
    _validTextInput.dispose();
    _pickerType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: ColorfoolAppBar(controller: _textController),
        body: FutureBuilder(
          future: _createOrGetColor(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _setupTextController();
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          SizedBox(
                            width: 180,
                            child: ValueListenableBuilder(
                              valueListenable: _validTextInput,
                              builder: (context, value, child) {
                                return TextField(
                                  controller: _textController,
                                  maxLength: 6,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                      counterText: '',
                                      hintText: "FFFFFF",
                                      hintStyle: const TextStyle(fontSize: 20),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          start: 12.0,
                                        ),
                                        child: Icon(
                                          Icons.grid_3x3_outlined,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      suffixIcon: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                          end: 30.0,
                                        ),
                                        child: Icon(
                                            _validTextInput.value
                                                ? Icons.check
                                                : Icons.close,
                                            color: _validTextInput.value
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                      hintMaxLines: 1,
                                      border: InputBorder.none),
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: _pickerType,
                          builder: (context, value, child) {
                            switch (value) {
                              case PickerType.material:
                                return MaterialPicker(
                                  pickerColor: _rawColor,
                                  onColorChanged: (Color color) {
                                    _rawColor = color;
                                    _textController.text =
                                        getFormattedColorCode(_rawColor)
                                            .toUpperCase();
                                  },
                                );
                              case PickerType.block:
                                return BlockPicker(
                                  pickerColor: _rawColor,
                                  onColorChanged: (Color color) {
                                    _rawColor = color;
                                    _textController.text =
                                        getFormattedColorCode(_rawColor)
                                            .toUpperCase();
                                  },
                                );
                              default:
                                return ColorPicker(
                                  pickerColor: _rawColor,
                                  onColorChanged: (Color color) {
                                    _rawColor = color;
                                    _textController.text =
                                        getFormattedColorCode(_rawColor)
                                            .toUpperCase();
                                  },
                                );
                            }
                          },
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _pickerType,
                        builder: (context, value, child) {
                          return ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _pickerType.value = PickerType.precise;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _pickerType.value == PickerType.precise
                                          ? Colors.deepPurple
                                          : Colors.blue,
                                ),
                                child: const Icon(Icons.loupe),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _pickerType.value = PickerType.material;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _pickerType.value == PickerType.material
                                          ? Colors.deepPurple
                                          : Colors.blue,
                                ),
                                child: const Icon(Icons.list_alt_outlined),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _pickerType.value = PickerType.block;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _pickerType.value == PickerType.block
                                          ? Colors.deepPurple
                                          : Colors.blue,
                                ),
                                child: const Icon(Icons.color_lens),
                              ),
                            ],
                          );
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _rawColor,
                        ),
                        onPressed: () {
                          _saveColorAndExit();
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                );
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
  final RegExp hex = RegExp(r'([a-fA-F0-9]{6})');

  void _setColor(String colorCode) {
    if (hex.hasMatch(colorCode)) {
      _color = Color(int.parse('ff$colorCode', radix: 16));
    }
  }

  bool _hasBeenSaved = false;

  @override
  void initState() {
    _setColor(widget.controller.text);
    _hasBeenSaved = (widget.controller.text != "");
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
      title: Text(_hasBeenSaved ? "Update Color" : "New Color"),
      backgroundColor: _color,
    );
  }
}
