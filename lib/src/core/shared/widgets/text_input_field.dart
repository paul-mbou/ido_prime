import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:material_ui/material_ui.dart';

class TextInputField extends StatelessWidget {
  final String name;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;
  final bool obscureText;
  const TextInputField({
    super.key,
    required this.name,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.obscureText = false,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return FormBuilderTextField(
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      validator: validator,
      style: TextStyle(color: onSurface, fontSize: 17),
      name: name,
      obscureText: obscureText,
      decoration:
          decoration ??
          InputDecoration(
            filled: true,
            hintText: hintText,
            prefixIcon: Icon(prefixIcon),
            suffixIcon: suffixIcon,
          ),
    );
  }
}
