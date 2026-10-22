import 'package:material_ui/material_ui.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';

class LabelledField extends StatelessWidget {
  final String label;
  final Widget child;
  const LabelledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: Color(0xFF8B7BAD),
          ),
        ),
        child,
      ],
    );
  }
}
