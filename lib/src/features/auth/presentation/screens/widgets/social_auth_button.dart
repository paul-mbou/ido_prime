import 'package:material_ui/material_ui.dart';

class SocialAuthButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback onPressed;
  const SocialAuthButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        minimumSize: Size(double.infinity, 48),
      ),
      onPressed: onPressed,
      label: Text(label),
      icon: icon,
    );
  }
}
