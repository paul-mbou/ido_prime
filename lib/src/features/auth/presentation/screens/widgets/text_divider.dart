import 'package:material_ui/material_ui.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';

class TextDivider extends StatelessWidget {
  final String text;
  const TextDivider({super.key, this.text = "or continue with"});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Expanded(child: Divider()),
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Color(0xFF8B7BAD),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
