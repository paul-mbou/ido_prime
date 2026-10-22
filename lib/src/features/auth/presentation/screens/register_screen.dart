import 'package:material_ui/material_ui.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/app_enums.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/input_validator.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_alert_dialog.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/shared/widgets/app_root_layout.dart';
import 'package:ido_prime/src/core/shared/widgets/app_text_loader.dart';
import 'package:ido_prime/src/core/shared/widgets/labelled_field.dart';
import 'package:ido_prime/src/core/shared/widgets/text_input_field.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/auth/presentation/provider/auth_notifier.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/auth_screen_header.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/email_field.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/widgets/password_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>(), const []);

    final registerUser = useCallback(() async {
      final form = formKey.currentState;
      if (form == null || !form.saveAndValidate()) return;
      final values = form.value;
      await ref
          .read(authNotifierProvider.notifier)
          .register(
            fullName: values['fullName'] as String,
            email: values['email'] as String,
            password: values['password'] as String,
          );
    }, const []);

    ref.listen(authNotifierProvider, (_, asyncAuthValue) {
      asyncAuthValue.whenOrNull(
        data: (authState) {
          if (authState == AppAuthState.userSignedUp) {
            context.showSnackBar("Account created successfully!");
            context.showAppDialog(
              barrierDismissible: false,
              builder: (context) => AppAlertDialog(
                icon: LucideIcons.mail,
                title: 'Verify your email',
                content:
                    'We\'ve sent a verification email to your inbox. Please check your email and click the link to verify your account.',
                actions: [
                  TextButton(
                    onPressed: () async {
                      final result = await launchUrl(Uri(scheme: 'mailto'));
                      if (context.mounted) {
                        if (!result) {
                          context.showErrorSnackBar('Failed to open mail app');
                        }
                        context.pop();
                      }
                    },
                    child: Text("Open mail app"),
                  ),
                ],
              ),
            );
          }
        },
        error: (error, stackTrace) =>
            context.showErrorSnackBar((error as AppAuthException).errorMessage),
      );
    });

    final isSigningUp = ref.watch(authNotifierProvider).isLoading;

    return AbsorbPointer(
      absorbing: isSigningUp,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const AppFrostedAppBar(),
        body: AppRootLayout(
          extendUnderAppBar: true,
          fillRemaining: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthScreenHeader(
                    title: "Create account",
                    subtitle: "Join Ido and start planning",
                  ),
                  GutterLarge(),
                  FormBuilder(
                    key: formKey,
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelledField(
                          label: "Full name",
                          child: TextInputField(
                            name: 'fullName',
                            hintText: "Nom et prénom",
                            prefixIcon: LucideIcons.user,
                            validator: InputValidator.checkName,
                          ),
                        ),
                        EmailField(name: 'email'),
                        PasswordField(name: 'password'),
                        PasswordField(
                          name: 'confirm_password',
                          isConfirmPasswordField: true,
                        ),
                      ],
                    ),
                  ),
                  Gutter(),
                  Text.rich(
                    TextSpan(
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8B7BAD),
                      ),
                      children: [
                        const TextSpan(text: 'By clicking on '),
                        TextSpan(
                          text: 'Create account',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' you agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GutterLarge(),
                  FilledButton.icon(
                    iconAlignment: IconAlignment.end,
                    icon: isSigningUp ? null : Icon(LucideIcons.arrowRight),
                    label: isSigningUp
                        ? AppTextLoader(text: "Creating account...")
                        : Text("Create account"),
                    onPressed: () async => await registerUser(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      TextButton(
                        child: Text("Sign in"),
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
