import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';

class AppAlertDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final List<Widget> actions;

  const AppAlertDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassDialog(
      title: Row(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const GutterSmall(),
          Expanded(child: Text(title)),
        ],
      ),
      actions: actions,
      child: Text(
        content,
        textAlign: TextAlign.start,
        style: context.textTheme.bodyLarge?.copyWith(height: 1.4),
      ),
    );
  }
}
