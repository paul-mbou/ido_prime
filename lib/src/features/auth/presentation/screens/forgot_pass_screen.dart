import 'package:material_ui/material_ui.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/shared/widgets/app_root_layout.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/auth_screen_header.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/email_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>(), [ref]);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppFrostedAppBar(),
      body: AppRootLayout(
        extendUnderAppBar: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthScreenHeader(
              title: "Forgot password",
              subtitle: "No worries! - Enter your email to reset your password",
            ),
            GutterLarge(),
            FormBuilder(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmailField(name: 'email'),
                  Gutter.custom(size: 20),

                  FilledButton.icon(
                    onPressed: () {
                      if (formKey.currentState?.saveAndValidate() ?? false) {
                        context.push(AppRoutes.otp);
                      }
                    },
                    iconAlignment: IconAlignment.end,
                    icon: Icon(LucideIcons.arrowRight),
                    label: Text("Send code"),
                  ),
                  Gutter(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Back to"),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text("Login"),
                        ),
                      ],
                    ),
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
