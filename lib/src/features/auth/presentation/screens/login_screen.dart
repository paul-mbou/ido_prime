import 'package:material_ui/material_ui.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/app_enums.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/generated/assets.gen.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_root_layout.dart';
import 'package:ido_prime/src/core/shared/widgets/app_text_loader.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/auth/presentation/provider/auth_notifier.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/auth_screen_header.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/email_field.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/password_field.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/social_auth_button.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/text_divider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>(), const []);
    ref.listen(authNotifierProvider, (_, asyncAuthValue) {
      asyncAuthValue.whenOrNull(
        data: (authState) {
          if (authState == AppAuthState.userLoggedIn) {
            context.go(AppRoutes.posts);
          }
        },
      );
    });

    final loginUser = useCallback(() async {
      final form = formKey.currentState;
      if (form == null || !form.saveAndValidate()) return;
      final values = form.value;
      await ref
          .read(authNotifierProvider.notifier)
          .login(
            email: values['email'] as String,
            password: values['password'] as String,
          );
    }, [formKey.currentState?.value.values.toList()]);

    final isLoggingIn = ref.watch(authNotifierProvider).isLoading;

    return AbsorbPointer(
      absorbing: isLoggingIn,
      child: Scaffold(
        body: AppRootLayout(
          fillRemaining: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  GutterLarge(),
                  Assets.svgs.idoLogo.svg(width: context.width * 0.05),
                  Gutter(),
                  AuthScreenHeader(
                    title: "Welcome back",
                    subtitle: "Sign in to continue",
                    isCentered: true,
                  ),
                  GutterLarge(),
                  FormBuilder(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EmailField(name: 'email'),
                        Gutter.custom(size: 20),
                        PasswordField(name: 'password'),
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.forgotPassword),
                            child: Text(
                              "Forgot password?",
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Gutter(),
                        FilledButton.icon(
                          onPressed: () async => await loginUser(),
                          iconAlignment: IconAlignment.end,
                          icon: isLoggingIn
                              ? null
                              : Icon(LucideIcons.arrowRight),
                          label: isLoggingIn
                              ? AppTextLoader(text: "Signing in...")
                              : Text("Sign In"),
                        ),
                        GutterLarge(),
                        TextDivider(),
                        GutterLarge(),
                        Row(
                          spacing: 20,
                          children: [
                            Expanded(
                              child: SocialAuthButton(
                                label: "Google",
                                onPressed: () {},
                                icon: Assets.svgs.googleIcon.svg(width: 16),
                              ),
                            ),
                            Expanded(
                              child: SocialAuthButton(
                                label: "Apple",
                                icon: Icon(Icons.apple),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        Gutter(),
                        SocialAuthButton(
                          label: "Facebook",
                          icon: Icon(Icons.facebook),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account ?"),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: Text("Sign up"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
