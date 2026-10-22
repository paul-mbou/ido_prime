import 'package:material_ui/material_ui.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/shared/widgets/app_root_layout.dart';
import 'package:ido_prime/src/core/shared/widgets/rounded_box_card.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/auth_screen_header.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/password_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NewPasswordScreen extends HookConsumerWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>(), [ref]);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppFrostedAppBar(),
      body: AppRootLayout(
        extendUnderAppBar: true,
        fillRemaining: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthScreenHeader(
              title: "Set new password",
              subtitle: "Enter your new password",
            ),
            GutterLarge(),
            FormBuilder(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PasswordField(name: 'password'),
                  Gutter.custom(size: 20),
                  PasswordField(
                    name: 'confirm_password',
                    isConfirmPasswordField: true,
                  ),
                  Gutter(),
                  _PasswordCheckList(),
                  GutterLarge(),
                  FilledButton.icon(
                    onPressed: () {
                      if (formKey.currentState?.saveAndValidate() ?? false) {
                        context.go(AppRoutes.login);
                      }
                    },
                    iconAlignment: IconAlignment.end,
                    label: Text("Reset password"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordCheckList extends StatelessWidget {
  const _PasswordCheckList();

  @override
  Widget build(BuildContext context) {
    return RoundedBoxCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 5,
          children: [
            _PasswordCheckListItem(
              title: "At least 8 characters",
              isChecked: true,
            ),
            _PasswordCheckListItem(title: "At least one uppercase letter"),
            _PasswordCheckListItem(title: "At least one lowercase letter"),
            _PasswordCheckListItem(title: "At least one number"),
          ],
        ),
      ),
    );
  }
}

class _PasswordCheckListItem extends StatelessWidget {
  const _PasswordCheckListItem({required this.title, this.isChecked = false});

  final String title;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Icon(
          isChecked ? LucideIcons.circleCheck : LucideIcons.circle,
          size: context.gutter,
          color: isChecked ? AppColors.muted : AppColors.onPrimary,
        ),
        Text(
          title,
          style: context.textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
