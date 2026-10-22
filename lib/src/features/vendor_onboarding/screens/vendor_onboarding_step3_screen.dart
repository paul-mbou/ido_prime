import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/providers/vendor_onboarding_providers.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VendorOnboardingStep3Screen extends HookConsumerWidget {
  const VendorOnboardingStep3Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biz = ref.watch(vendorBusinessProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;

    final idDoc = useState(biz.idDocumentLabel);
    final bizDoc = useState(biz.businessDocumentLabel);
    final saving = useState(false);

    Future<void> save({required bool submit}) async {
      if (submit && (!biz.step1Done || !biz.step2Done)) {
        context.showErrorSnackBar(
          'Complete steps 1 and 2 before submitting for review',
        );
        return;
      }
      if (submit && (idDoc.value.isEmpty || bizDoc.value.isEmpty)) {
        context.showErrorSnackBar('Attach both documents before submitting');
        return;
      }
      saving.value = true;
      await ref
          .read(vendorBusinessProvider.notifier)
          .saveStep3(
            idDocumentLabel: idDoc.value,
            businessDocumentLabel: bizDoc.value,
            submitForReview: submit,
          );
      saving.value = false;
      if (!context.mounted) return;
      context.showSnackBar(
        submit
            ? 'Submitted — IDO will verify on the field'
            : 'Documents saved as draft',
      );
      if (submit) context.pop();
    }

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'Step 3 · KYC / KYB',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, gutter, gutter, gutter),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                Text(
                  'Verification documents',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const GutterTiny(),
                Text(
                  'IDO reviews KYC/KYB and may verify on the field before you '
                  'can offer services in discovery.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const Gutter(),
                _DocTile(
                  title: 'Identity document',
                  subtitle: idDoc.value.isEmpty
                      ? 'National ID or passport (mock pick)'
                      : idDoc.value,
                  attached: idDoc.value.isNotEmpty,
                  onTap: () => idDoc.value = 'ID_card_front.pdf',
                ),
                const GutterSmall(),
                _DocTile(
                  title: 'Business document',
                  subtitle: bizDoc.value.isEmpty
                      ? 'Registration or tax ID (mock pick)'
                      : bizDoc.value,
                  attached: bizDoc.value.isNotEmpty,
                  onTap: () => bizDoc.value = 'business_registration.pdf',
                ),
                if (biz.status == VendorBusinessStatus.pendingReview) ...[
                  const Gutter(),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(LucideIcons.shieldCheck, color: colors.primary),
                          const GutterSmall(),
                          Expanded(
                            child: Text(
                              'Under IDO review — you cannot offer services yet.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                    ]),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 12),
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: saving.value ? null : () => save(submit: false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Save draft'),
                  ),
                  const GutterSmall(),
                  FilledButton(
                    onPressed: saving.value ? null : () => save(submit: true),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: const Text('Submit for IDO review'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.title,
    required this.subtitle,
    required this.attached,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool attached;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: attached
                  ? AppColors.primary
                  : colors.outline.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: [
              Icon(
                attached ? LucideIcons.fileCheck2 : LucideIcons.fileUp,
                color: attached ? AppColors.primary : colors.onSurfaceVariant,
              ),
              const Gutter(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const GutterTiny(),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
