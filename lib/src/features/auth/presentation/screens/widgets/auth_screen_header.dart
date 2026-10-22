import 'package:material_ui/material_ui.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';

class AuthScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCentered;
  const AuthScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.isCentered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isCentered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          subtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Color(0xFF8B7BAD),
          ),
        ),
      ],
    );
  }
}
