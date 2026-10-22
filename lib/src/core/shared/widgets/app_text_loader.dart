import 'package:material_ui/material_ui.dart';

class AppTextLoader extends StatelessWidget {
  final String text;
  const AppTextLoader({super.key, this.text = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    final textStyle = DefaultTextStyle.of(context).style;
    final size = textStyle.fontSize ?? 14;
    final color = textStyle.color ?? IconTheme.of(context).color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        SizedBox.square(
          dimension: size,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: (size / 8).clamp(1.5, 3),
          ),
        ),
        Text(text),
      ],
    );
  }
}
