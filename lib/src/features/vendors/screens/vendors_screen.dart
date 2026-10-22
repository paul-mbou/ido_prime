import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_root_layout.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/utils/active_space_gate.dart';
import 'package:ido_prime/src/features/vendors/models/vendor.dart';
import 'package:ido_prime/src/features/vendors/providers/vendor_connection_provider.dart';
import 'package:ido_prime/src/features/vendors/widgets/ai_matched_vendors_banner.dart';
import 'package:ido_prime/src/features/vendors/widgets/vendor_card.dart';
import 'package:ido_prime/src/features/vendors/widgets/vendor_category_chips.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VendorsScreen extends HookConsumerWidget {
  const VendorsScreen({super.key, this.eventId});

  /// When set, contact requests are scoped to this event.
  final String? eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = useState(vendorCategories.first);
    final colors = Theme.of(context).colorScheme;
    final scopedEventId = eventId;

    final vendors = mockVendors
        .where(
          (vendor) =>
              selectedCategory.value == 'All' ||
              vendor.category == selectedCategory.value,
        )
        .toList(growable: false);

    Future<void> contactVendor(Vendor vendor) {
      return runInActiveSpace(
        context,
        ref,
        requiredSpace: ActiveSpace.planner,
        actionLabel: 'contact a vendor',
        message:
            'Vendor accounts can’t contact other vendors. '
            'Switch to Planner to send a request.',
        action: () {
          final status = ref.read(vendorConnectionProvider(vendor.id))?.status;
          if (status == VendorConnectionStatus.accepted) {
            context.push(AppRoutes.vendorChat(vendor.id));
          } else {
            context.push(
              AppRoutes.vendorContact(vendor.id, eventId: scopedEventId),
            );
          }
        },
      );
    }

    return AppRootLayout(
      extendUnderAppBar: true,
      padding: EdgeInsets.fromLTRB(context.gutter, 0, context.gutter, 100),
      children: [
        Text(
          'Find vendors',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const GutterSmall(),
        VendorCategoryChips(
          categories: vendorCategories,
          selected: selectedCategory.value,
          onSelected: (value) => selectedCategory.value = value,
        ),
        const Gutter(),
        AiMatchedVendorsBanner(matchCount: 12),
        const Gutter(),
        if (vendors.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.gutterLarge * 2),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.store,
                    size: 40,
                    color: colors.onSurfaceVariant,
                  ),
                  const GutterSmall(),
                  Text(
                    'No vendors found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final vendor in vendors) ...[
            VendorCard(
              vendor: vendor,
              onContact: () => contactVendor(vendor),
              onViewProfile: () =>
                  context.push(AppRoutes.vendorProfile(vendor.id)),
            ),
            const Gutter(),
          ],
      ],
    );
  }
}
