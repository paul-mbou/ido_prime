import 'package:material_ui/material_ui.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';

class RoundedBoxCard extends StatelessWidget {
  final Widget child;
  const RoundedBoxCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      child: child,
    );
  }
}
