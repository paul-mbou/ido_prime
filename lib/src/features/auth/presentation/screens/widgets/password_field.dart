import 'package:material_ui/material_ui.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/input_validator.dart';
import 'package:ido_prime/src/core/shared/widgets/labelled_field.dart';
import 'package:ido_prime/src/core/shared/widgets/text_input_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PasswordField extends HookConsumerWidget {
  final String name;
  final bool isConfirmPasswordField;
  final String passwordFieldName;

  const PasswordField({
    super.key,
    required this.name,
    this.isConfirmPasswordField = false,
    this.passwordFieldName = 'password',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obscureText = useState(true);

    return LabelledField(
      label: isConfirmPasswordField ? 'Confirm password' : 'Password',
      child: TextInputField(
        name: name,
        hintText: '••••••••',
        obscureText: obscureText.value,
        prefixIcon: LucideIcons.lock,
        suffixIcon: IconButton(
          onPressed: () => obscureText.value = !obscureText.value,
          icon: Icon(obscureText.value ? LucideIcons.eye : LucideIcons.eyeOff),
        ),
        validator: isConfirmPasswordField
            ? (value) {
                final password = FormBuilder.of(
                  context,
                )?.instantValue[passwordFieldName]?.toString();
                return InputValidator.checkConfirmPassword(password, value);
              }
            : InputValidator.checkPassword,
      ),
    );
  }
}
