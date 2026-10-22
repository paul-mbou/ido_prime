import 'package:material_ui/material_ui.dart';
import 'package:ido_prime/src/core/input_validator.dart';
import 'package:ido_prime/src/core/shared/widgets/labelled_field.dart';
import 'package:ido_prime/src/core/shared/widgets/text_input_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmailField extends TextInputField {
  const EmailField({super.key, required super.name});

  @override
  Widget build(BuildContext context) {
    return LabelledField(
      label: 'Email',
      child: TextInputField(
        name: name,
        hintText: "you@example.com",
        prefixIcon: LucideIcons.mail,
        validator: InputValidator.checkEmail,
      ),
    );
  }
}
