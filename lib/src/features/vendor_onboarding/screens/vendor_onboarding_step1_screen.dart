import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/providers/vendor_onboarding_providers.dart';

class VendorOnboardingStep1Screen extends HookConsumerWidget {
  const VendorOnboardingStep1Screen({super.key});

  static const _countries = [
    'Cameroon',
    'France',
    'Senegal',
    'Ivory Coast',
    'United States',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biz = ref.watch(vendorBusinessProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;

    final nameCtrl = useTextEditingController(text: biz.displayName);
    final photoCtrl = useTextEditingController(text: biz.photoUrl);
    final country = useState(
      biz.country.isEmpty ? _countries.first : biz.country,
    );
    final availability = useState(biz.availability);
    final saving = useState(false);

    useEffect(() {
      nameCtrl.text = biz.displayName;
      photoCtrl.text = biz.photoUrl;
      return null;
    }, [biz.id]);

    Future<void> save({required bool popAfter}) async {
      saving.value = true;
      await ref
          .read(vendorBusinessProvider.notifier)
          .saveStep1(
            displayName: nameCtrl.text,
            photoUrl: photoCtrl.text.isEmpty
                ? VendorBusiness.empty().photoUrl
                : photoCtrl.text,
            country: country.value,
            availability: availability.value,
          );
      saving.value = false;
      if (!context.mounted) return;
      context.showSnackBar(
        nameCtrl.text.trim().isEmpty
            ? 'Draft saved'
            : 'Business identity saved',
      );
      if (popAfter) context.pop();
    }

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'Step 1 · Identity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, gutter, gutter, gutter),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        'Business identity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const GutterTiny(),
                      Text(
                        'You can save a draft and finish later.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const Gutter(),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: AppCachedNetworkImage(
                              imageUrl: photoCtrl.text.isEmpty
                                  ? VendorBusiness.empty().photoUrl
                                  : photoCtrl.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const Gutter(),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Business name',
                          hintText: 'e.g. Gourmet Catering Co.',
                        ),
                      ),
                      const Gutter(),
                      TextField(
                        controller: photoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Photo URL',
                          hintText: 'https://…',
                        ),
                        onChanged: (_) {},
                      ),
                      const Gutter(),
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _countries.contains(country.value)
                            ? country.value
                            : _countries.first,
                        decoration: const InputDecoration(labelText: 'Country'),
                        items: [
                          for (final c in _countries)
                            DropdownMenuItem(value: c, child: Text(c)),
                        ],
                        onChanged: (v) {
                          if (v != null) country.value = v;
                        },
                      ),
                      const Gutter(),
                      Text(
                        'Availability',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const GutterSmall(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final option in VendorAvailability.values)
                            ChoiceChip(
                              label: Text(option.label),
                              selected: availability.value == option,
                              showCheckmark: false,
                              onSelected: (_) => availability.value = option,
                            ),
                        ],
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
                      child: saving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save & continue'),
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
