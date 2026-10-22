import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
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
import 'package:pinput/pinput.dart';

class OtpScreen extends HookConsumerWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinController = useTextEditingController();
    final focusNode = useFocusNode();
    useListenable(pinController);
    final isCodeValid = pinController.text.length == 6;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppFrostedAppBar(),
      body: AppRootLayout(
        extendUnderAppBar: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthScreenHeader(
              title: "Verify your email",
              subtitle: "Enter the code sent to your email address",
            ),
            GutterLarge(),
            _OtpInputField(pinController: pinController, focusNode: focusNode),

            GutterLarge(),
            FilledButton(
              onPressed: isCodeValid
                  ? () => context.push(AppRoutes.newPassword)
                  : null,
              child: Text("Verify code"),
            ),
            Gutter(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive the code?"),
                TextButton(onPressed: () {}, child: Text("Resend")),
              ],
            ),
            GutterLarge(),
            RoundedBoxCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "💡 Check your spam folder if you don't see the email. The code expires in 10 minutes.",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Color(0xFF8B7BAD),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpInputField extends StatelessWidget {
  const _OtpInputField({required this.pinController, required this.focusNode});

  final TextEditingController pinController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    // Define the default pin theme
    final defaultPinTheme = PinTheme(
      constraints: BoxConstraints(
        minWidth: context.width,
        minHeight: context.height * 0.025,
      ),

      textStyle: const TextStyle(fontSize: 24, color: Colors.white),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.outline, width: 1),
        ),
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surface,
      ),
    );

    // Define the focused pin theme
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: const Border.fromBorderSide(
        BorderSide(color: AppColors.primary, width: 2),
      ),
    );

    // Define the submitted pin theme
    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: const Border.fromBorderSide(
        BorderSide(color: Colors.white, width: 2),
      ),
    );

    // Define the error pin theme
    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: const Border.fromBorderSide(
        BorderSide(color: Colors.red, width: 2),
      ),
    );

    return Pinput(
      autofocus: true,
      controller: pinController,
      focusNode: focusNode,
      length: 6,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,
      cursor: Container(
        width: 2,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      onCompleted: (otpCode) {},
      validator: (pin) {
        // Add validation logic here
        if (pin != null && pin.length == 6) {
          // You can add specific validation logic here
          // For now, we'll accept any 6-digit code
          return null;
        }
        return 'Please enter a valid 6-digit code';
      },
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
    );
  }
}
