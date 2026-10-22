import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/providers/vendor_onboarding_providers.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Owner view of the vendor vitrine — same layout as the public profile,
/// with per-section edit actions.
class VendorManageProfileScreen extends HookConsumerWidget {
  const VendorManageProfileScreen({super.key});

  static const _sampleGalleryUrls = <String>[
    'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
    'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
    'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
    'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&q=80',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biz = ref.watch(vendorBusinessProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;
    final frosted = useState(false);

    final name = biz.displayName.isEmpty ? 'Your business' : biz.displayName;
    final category = biz.category.isEmpty ? 'Add a category' : biz.category;
    final location = biz.country.isEmpty ? 'Add location' : biz.country;
    final photoUrl = biz.photoUrl.isEmpty
        ? VendorBusiness.empty().photoUrl
        : biz.photoUrl;
    final serviceLabels = biz.services
        .where((s) => s.name.trim().isNotEmpty)
        .map(
          (s) => s.priceLabel.trim().isEmpty
              ? s.name
              : '${s.name} · ${s.priceLabel}',
        )
        .toList();

    final appBarExtent = MediaQuery.paddingOf(context).top + kToolbarHeight + 1;

    Future<void> editPhoto() async {
      final next = await _promptText(
        context,
        title: 'Cover / profile photo URL',
        initial: photoUrl,
        hint: 'https://…',
      );
      if (next == null) return;
      await ref
          .read(vendorBusinessProvider.notifier)
          .updateProfilePicture(next);
      if (context.mounted) context.showSnackBar('Photo updated');
    }

    Future<void> editIdentity() async {
      final result = await showModalBottomSheet<_IdentityDraft>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => _IdentityEditorSheet(
          name: biz.displayName,
          category: biz.category,
          country: biz.country,
          availability: biz.availability,
        ),
      );
      if (result == null) return;
      await ref
          .read(vendorBusinessProvider.notifier)
          .saveStep1(
            displayName: result.name,
            photoUrl: photoUrl,
            country: result.country,
            availability: result.availability,
          );
      await ref
          .read(vendorBusinessProvider.notifier)
          .updateBioAndContact(
            bio: biz.bio,
            category: result.category,
            phone: biz.phone,
            email: biz.email,
          );
      if (context.mounted) context.showSnackBar('Business info updated');
    }

    Future<void> editAbout() async {
      final next = await _promptText(
        context,
        title: 'About your business',
        initial: biz.bio,
        hint: 'Tell planners what you offer…',
        minLines: 4,
        maxLines: 8,
      );
      if (next == null) return;
      await ref
          .read(vendorBusinessProvider.notifier)
          .updateBioAndContact(
            bio: next,
            category: biz.category,
            phone: biz.phone,
            email: biz.email,
          );
      if (context.mounted) context.showSnackBar('About updated');
    }

    Future<void> editServices() async {
      final result = await showModalBottomSheet<_ServicesDraft>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => _ServicesEditorSheet(
          services: biz.services.isEmpty
              ? [const VendorServiceOffer(name: '', priceLabel: '')]
              : List.of(biz.services),
          modalities: biz.modalities,
        ),
      );
      if (result == null) return;
      await ref
          .read(vendorBusinessProvider.notifier)
          .saveStep2(services: result.services, modalities: result.modalities);
      if (context.mounted) context.showSnackBar('Services updated');
    }

    Future<void> addGalleryPhoto() async {
      final index = biz.gallery.length % _sampleGalleryUrls.length;
      await ref
          .read(vendorBusinessProvider.notifier)
          .addGalleryItem(
            VendorGalleryItem(
              imageUrl: _sampleGalleryUrls[index],
              eventName: 'Past event ${biz.gallery.length + 1}',
              caption: 'Proof of work',
            ),
          );
      if (context.mounted) context.showSnackBar('Past event photo added');
    }

    Future<void> editContact() async {
      final result = await showModalBottomSheet<_ContactDraft>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) =>
            _ContactEditorSheet(phone: biz.phone, email: biz.email),
      );
      if (result == null) return;
      await ref
          .read(vendorBusinessProvider.notifier)
          .updateBioAndContact(
            bio: biz.bio,
            category: biz.category,
            phone: result.phone,
            email: result.email,
          );
      if (context.mounted) context.showSnackBar('Contact updated');
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppFrostedAppBar(
        frosted: frosted.value,
        title: Text(
          'My vendor profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.vendorOnboardingHub),
            child: const Text('Setup'),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          final next = n.metrics.pixels > 2;
          if (next != frosted.value) frosted.value = next;
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  appBarExtent + gutter,
                  gutter,
                  gutter,
                ),
                children: [
                  if (!biz.canOfferServices) ...[
                    _OwnerHintBanner(text: biz.progressSubtitle),
                    const Gutter(),
                  ],
                  _EditableHero(photoUrl: photoUrl, onEdit: editPhoto),
                  const Gutter(),
                  _EditableIdentity(
                    name: name,
                    category: category,
                    location: location,
                    availability: biz.availability.label,
                    verified: biz.canOfferServices,
                    onEdit: editIdentity,
                  ),
                  const Gutter(),
                  _OwnerStatsRow(
                    serviceCount: serviceLabels.length,
                    galleryCount: biz.gallery.length,
                    availability: biz.availability.label,
                  ),
                  const Gutter(),
                  _EditableSection(
                    title: 'About',
                    onEdit: editAbout,
                    child: Text(
                      biz.bio.isEmpty
                          ? 'Tap edit to introduce your business to planners.'
                          : biz.bio,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                        color: biz.bio.isEmpty
                            ? colors.onSurfaceVariant
                            : colors.onSurface,
                      ),
                    ),
                  ),
                  const Gutter(),
                  _EditableSection(
                    title: 'Services',
                    onEdit: editServices,
                    child: serviceLabels.isEmpty
                        ? Text(
                            'Add services and pricing so planners know what you offer.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.45,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final label in serviceLabels)
                                _ServiceChip(label: label),
                            ],
                          ),
                  ),
                  const Gutter(),
                  _EditableSection(
                    title: 'Past events gallery',
                    editLabel: 'Add',
                    editIcon: LucideIcons.imagePlus,
                    onEdit: addGalleryPhoto,
                    child: biz.gallery.isEmpty
                        ? Text(
                            'Photos of events you organized — social proof for planners.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.45,
                            ),
                          )
                        : SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: biz.gallery.length,
                              separatorBuilder: (_, _) => const GutterSmall(),
                              itemBuilder: (context, index) {
                                final item = biz.gallery[index];
                                return _OwnerGalleryTile(
                                  item: item,
                                  onRemove: () => ref
                                      .read(vendorBusinessProvider.notifier)
                                      .removeGalleryItemAt(index),
                                );
                              },
                            ),
                          ),
                  ),
                  const Gutter(),
                  _EditableSection(
                    title: 'Details',
                    onEdit: editContact,
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: LucideIcons.mapPin,
                          label: 'Location',
                          value: location,
                          muted: biz.country.isEmpty,
                        ),
                        const GutterSmall(),
                        _DetailRow(
                          icon: LucideIcons.clock3,
                          label: 'Availability',
                          value: biz.availability.label,
                        ),
                        const GutterSmall(),
                        _DetailRow(
                          icon: LucideIcons.phone,
                          label: 'Phone',
                          value: biz.phone.isEmpty ? 'Add phone' : biz.phone,
                          muted: biz.phone.isEmpty,
                        ),
                        const GutterSmall(),
                        _DetailRow(
                          icon: LucideIcons.mail,
                          label: 'Email',
                          value: biz.email.isEmpty ? 'Add email' : biz.email,
                          muted: biz.email.isEmpty,
                        ),
                        if (biz.modalities.trim().isNotEmpty) ...[
                          const GutterSmall(),
                          _DetailRow(
                            icon: LucideIcons.fileText,
                            label: 'Modalities',
                            value: biz.modalities,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: theme.navigationBarTheme.backgroundColor ?? colors.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 10, gutter, 10),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.vendorOnboardingHub),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(LucideIcons.listChecks, size: 18),
                    label: const Text('Onboarding & KYC'),
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

Future<String?> _promptText(
  BuildContext context, {
  required String title,
  required String initial,
  String? hint,
  int minLines = 1,
  int maxLines = 1,
}) {
  final controller = TextEditingController(text: initial);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                ctx,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gutter(),
            TextField(
              controller: controller,
              autofocus: true,
              minLines: minLines,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                alignLabelWithHint: minLines > 1,
              ),
            ),
            const Gutter(),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    },
  );
}

class _IdentityDraft {
  const _IdentityDraft({
    required this.name,
    required this.category,
    required this.country,
    required this.availability,
  });

  final String name;
  final String category;
  final String country;
  final VendorAvailability availability;
}

class _ServicesDraft {
  const _ServicesDraft({required this.services, required this.modalities});

  final List<VendorServiceOffer> services;
  final String modalities;
}

class _ContactDraft {
  const _ContactDraft({required this.phone, required this.email});

  final String phone;
  final String email;
}

class _OwnerHintBanner extends StatelessWidget {
  const _OwnerHintBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(LucideIcons.info, color: theme.colorScheme.primary),
            const GutterSmall(),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableHero extends StatelessWidget {
  const _EditableHero({required this.photoUrl, required this.onEdit});

  final String photoUrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 11,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppCachedNetworkImage(
            imageUrl: photoUrl,
            borderRadius: BorderRadius.circular(20),
            fit: BoxFit.cover,
            errorWidget: ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(LucideIcons.imageOff, color: colors.onSurfaceVariant),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: _EditPill(label: 'Edit photo', onTap: onEdit),
          ),
        ],
      ),
    );
  }
}

class _EditableIdentity extends StatelessWidget {
  const _EditableIdentity({
    required this.name,
    required this.category,
    required this.location,
    required this.availability,
    required this.verified,
    required this.onEdit,
  });

  final String name;
  final String category;
  final String location;
  final String availability;
  final bool verified;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (verified) ...[
                    const GutterTiny(),
                    Icon(
                      LucideIcons.badgeCheck,
                      size: 22,
                      color: colors.primary,
                    ),
                  ],
                ],
              ),
            ),
            const GutterSmall(),
            _EditIconButton(onTap: onEdit),
          ],
        ),
        const GutterTiny(),
        Text(
          category,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const GutterTiny(),
        Row(
          children: [
            Icon(LucideIcons.mapPin, size: 15, color: colors.onSurfaceVariant),
            const Gutter.custom(size: 4),
            Expanded(
              child: Text(
                location,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const GutterTiny(),
        Row(
          children: [
            Icon(LucideIcons.clock3, size: 15, color: colors.onSurfaceVariant),
            const Gutter.custom(size: 4),
            Text(
              availability,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OwnerStatsRow extends StatelessWidget {
  const _OwnerStatsRow({
    required this.serviceCount,
    required this.galleryCount,
    required this.availability,
  });

  final int serviceCount;
  final int galleryCount;
  final String availability;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: _StatCell(value: '$serviceCount', label: 'Services'),
            ),
            Expanded(
              child: _StatCell(value: '$galleryCount', label: 'Photos'),
            ),
            Expanded(
              child: _StatCell(
                value: availability.split(' ').first,
                label: 'Avail.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const GutterTiny(),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EditableSection extends StatelessWidget {
  const _EditableSection({
    required this.title,
    required this.onEdit,
    required this.child,
    this.editLabel = 'Edit',
    this.editIcon = LucideIcons.pencil,
  });

  final String title;
  final VoidCallback onEdit;
  final Widget child;
  final String editLabel;
  final IconData editIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(editIcon, size: 15),
                  label: Text(editLabel),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const GutterTiny(),
            Padding(padding: const EdgeInsets.only(right: 6), child: child),
          ],
        ),
      ),
    );
  }
}

class _EditPill extends StatelessWidget {
  const _EditPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.camera, size: 14, color: Colors.white),
              const Gutter.custom(size: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditIconButton extends StatelessWidget {
  const _EditIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(LucideIcons.pencil, size: 16, color: colors.primary),
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const GutterSmall(),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: muted ? colors.onSurfaceVariant : colors.onSurface,
              fontStyle: muted ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _OwnerGalleryTile extends StatelessWidget {
  const _OwnerGalleryTile({required this.item, required this.onRemove});

  final VendorGalleryItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 160,
        height: 120,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppCachedNetworkImage(imageUrl: item.imageUrl, fit: BoxFit.cover),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(LucideIcons.x, size: 14, color: Colors.white),
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

class _IdentityEditorSheet extends HookWidget {
  const _IdentityEditorSheet({
    required this.name,
    required this.category,
    required this.country,
    required this.availability,
  });

  final String name;
  final String category;
  final String country;
  final VendorAvailability availability;

  @override
  Widget build(BuildContext context) {
    final nameCtrl = useTextEditingController(text: name);
    final categoryCtrl = useTextEditingController(text: category);
    final countryCtrl = useTextEditingController(text: country);
    final avail = useState(availability);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Business info',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gutter(),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Business name'),
            ),
            const GutterSmall(),
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Catering, Florals…',
              ),
            ),
            const GutterSmall(),
            TextField(
              controller: countryCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const Gutter(),
            Text(
              'Availability',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const GutterSmall(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in VendorAvailability.values)
                  ChoiceChip(
                    label: Text(option.label),
                    selected: avail.value == option,
                    showCheckmark: false,
                    onSelected: (_) => avail.value = option,
                  ),
              ],
            ),
            const Gutter(),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _IdentityDraft(
                    name: nameCtrl.text.trim(),
                    category: categoryCtrl.text.trim(),
                    country: countryCtrl.text.trim(),
                    availability: avail.value,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesEditorSheet extends HookWidget {
  const _ServicesEditorSheet({
    required this.services,
    required this.modalities,
  });

  final List<VendorServiceOffer> services;
  final String modalities;

  @override
  Widget build(BuildContext context) {
    final offers = useState(List<VendorServiceOffer>.from(services));
    final modalitiesCtrl = useTextEditingController(text: modalities);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Services & pricing',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    offers.value = [
                      ...offers.value,
                      const VendorServiceOffer(name: '', priceLabel: ''),
                    ];
                  },
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
            const Gutter(),
            for (var i = 0; i < offers.value.length; i++) ...[
              if (i > 0) const Gutter(),
              Row(
                children: [
                  Text(
                    'Service ${i + 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (offers.value.length > 1)
                    IconButton(
                      onPressed: () {
                        final next = List<VendorServiceOffer>.from(offers.value)
                          ..removeAt(i);
                        offers.value = next;
                      },
                      icon: const Icon(LucideIcons.trash2, size: 18),
                    ),
                ],
              ),
              TextFormField(
                initialValue: offers.value[i].name,
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (v) {
                  final next = List<VendorServiceOffer>.from(offers.value);
                  next[i] = VendorServiceOffer(
                    name: v,
                    priceLabel: next[i].priceLabel,
                  );
                  offers.value = next;
                },
              ),
              const GutterSmall(),
              TextFormField(
                initialValue: offers.value[i].priceLabel,
                decoration: const InputDecoration(labelText: 'Price'),
                onChanged: (v) {
                  final next = List<VendorServiceOffer>.from(offers.value);
                  next[i] = VendorServiceOffer(
                    name: next[i].name,
                    priceLabel: v,
                  );
                  offers.value = next;
                },
              ),
            ],
            const Gutter(),
            TextField(
              controller: modalitiesCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Modalities',
                hintText: 'Deposit, radius, lead time…',
                alignLabelWithHint: true,
              ),
            ),
            const Gutter(),
            FilledButton(
              onPressed: () {
                final cleaned = offers.value
                    .where(
                      (s) =>
                          s.name.trim().isNotEmpty ||
                          s.priceLabel.trim().isNotEmpty,
                    )
                    .map(
                      (s) => VendorServiceOffer(
                        name: s.name.trim(),
                        priceLabel: s.priceLabel.trim(),
                      ),
                    )
                    .toList();
                Navigator.pop(
                  context,
                  _ServicesDraft(
                    services: cleaned,
                    modalities: modalitiesCtrl.text.trim(),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactEditorSheet extends HookWidget {
  const _ContactEditorSheet({required this.phone, required this.email});

  final String phone;
  final String email;

  @override
  Widget build(BuildContext context) {
    final phoneCtrl = useTextEditingController(text: phone);
    final emailCtrl = useTextEditingController(text: email);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Contact details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gutter(),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const GutterSmall(),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const Gutter(),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                _ContactDraft(
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
