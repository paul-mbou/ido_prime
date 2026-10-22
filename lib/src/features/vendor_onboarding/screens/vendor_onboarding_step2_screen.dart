import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/providers/vendor_onboarding_providers.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VendorOnboardingStep2Screen extends HookConsumerWidget {
  const VendorOnboardingStep2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biz = ref.watch(vendorBusinessProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;

    final services = useState<List<VendorServiceOffer>>(
      biz.services.isEmpty
          ? [const VendorServiceOffer(name: '', priceLabel: '')]
          : List.of(biz.services),
    );
    final modalitiesCtrl = useTextEditingController(text: biz.modalities);
    final saving = useState(false);

    Future<void> save({required bool popAfter}) async {
      saving.value = true;
      final cleaned = services.value
          .where(
            (s) => s.name.trim().isNotEmpty || s.priceLabel.trim().isNotEmpty,
          )
          .map(
            (s) => VendorServiceOffer(
              name: s.name.trim(),
              priceLabel: s.priceLabel.trim(),
            ),
          )
          .toList();
      await ref
          .read(vendorBusinessProvider.notifier)
          .saveStep2(services: cleaned, modalities: modalitiesCtrl.text);
      saving.value = false;
      if (!context.mounted) return;
      context.showSnackBar('Services saved');
      if (popAfter) context.pop();
    }

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'Step 2 · Services',
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
                  'Services & pricing',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const GutterTiny(),
                Text(
                  'Add at least one service with a price label, plus your modalities.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Gutter(),
                for (var i = 0; i < services.value.length; i++) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.outline.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Service ${i + 1}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              if (services.value.length > 1)
                                IconButton(
                                  onPressed: () {
                                    final next = List<VendorServiceOffer>.from(
                                      services.value,
                                    )..removeAt(i);
                                    services.value = next;
                                  },
                                  icon: Icon(
                                    LucideIcons.trash2,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          TextFormField(
                            initialValue: services.value[i].name,
                            decoration: const InputDecoration(
                              labelText: 'Service name',
                              hintText: 'e.g. Plated dinner',
                            ),
                            onChanged: (v) {
                              final next = List<VendorServiceOffer>.from(
                                services.value,
                              );
                              next[i] = VendorServiceOffer(
                                name: v,
                                priceLabel: next[i].priceLabel,
                              );
                              services.value = next;
                            },
                          ),
                          const GutterSmall(),
                          TextFormField(
                            initialValue: services.value[i].priceLabel,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              hintText: 'e.g. From 250,000 XAF',
                            ),
                            onChanged: (v) {
                              final next = List<VendorServiceOffer>.from(
                                services.value,
                              );
                              next[i] = VendorServiceOffer(
                                name: next[i].name,
                                priceLabel: v,
                              );
                              services.value = next;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gutter(),
                ],
                OutlinedButton.icon(
                  onPressed: () {
                    services.value = [
                      ...services.value,
                      const VendorServiceOffer(name: '', priceLabel: ''),
                    ];
                  },
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Add service'),
                ),
                const Gutter(),
                TextField(
                  controller: modalitiesCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Modalities',
                    hintText:
                        'Deposit, travel radius, lead time, cancellation…',
                    alignLabelWithHint: true,
                  ),
                ),
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: saving.value
                          ? null
                          : () => save(popAfter: false),
                      child: const Text('Save draft'),
                    ),
                  ),
                  const GutterSmall(),
                  Expanded(
                    child: FilledButton(
                      onPressed: saving.value
                          ? null
                          : () => save(popAfter: true),
                      child: const Text('Save & continue'),
                    ),
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
