import 'package:flutter/material.dart';

typedef CharacterFormFieldControl = ({
  GlobalKey<FormFieldState> key,
  FocusNode focus,
  TextEditingController controller,
});

class CharacterFormFieldsController {
  final CharacterFormFieldControl name = _createField();

  List<CharacterFormFieldControl> get fields => [name];

  static CharacterFormFieldControl _createField() {
    return (
      key: GlobalKey<FormFieldState>(),
      focus: FocusNode(),
      controller: TextEditingController(),
    );
  }

  void clear() {
    for (final field in fields) {
      field.controller.clear();
    }
  }

  void dispose() {
    for (final field in fields) {
      field.focus.dispose();
      field.controller.dispose();
    }
  }
}