import 'package:flutter/material.dart';

class CheckboxListTileFormField extends FormField<bool> {
  CheckboxListTileFormField({
    required bool initialValue,
    FormFieldSetter<bool>? onSaved,
    Widget? title,
  }) : super(
          initialValue: initialValue,
          onSaved: onSaved,
          builder: (field) {
            return CheckboxListTile(
              title: title,
              value: field.value,
              onChanged: field.didChange,
            );
          },
        );
}
