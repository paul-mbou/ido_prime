import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Ticket page editor for paid events (organizer view).
class EventTicketsSection extends ConsumerStatefulWidget {
  const EventTicketsSection({super.key, required this.event});

  final Event event;

  @override
  ConsumerState<EventTicketsSection> createState() =>
      _EventTicketsSectionState();
}

class _EventTicketsSectionState extends ConsumerState<EventTicketsSection> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    final page = widget.event.ticketPage;
    _titleCtrl = TextEditingController(
      text: page.title.isEmpty
          ? '${widget.event.title} — Tickets'
          : page.title,
    );
    _descCtrl = TextEditingController(text: page.description);
    _priceCtrl = TextEditingController(
      text: page.price > 0 ? page.price.round().toString() : '',
    );
    _qtyCtrl = TextEditingController(
      text: page.quantity > 0
          ? page.quantity.toString()
          : widget.event.guestCount.toString(),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _save({bool publish = false}) {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    final page = EventTicketPage(
      title: _titleCtrl.text.trim().isEmpty
          ? '${widget.event.title} — Tickets'
          : _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: price < 0 ? 0 : price,
      quantity: qty < 0 ? 0 : qty,
      isPublished: publish || widget.event.ticketPage.isPublished,
    );
    ref.read(eventsProvider.notifier).updateTicketPage(widget.event.id, page);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          publish || page.isPublished
              ? 'Ticket page published'
              : 'Ticket page saved',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final page = widget.event.ticketPage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.info,
                  size: 18,
                  color: AppColors.primary,
                ),
                const GutterSmall(),
                Expanded(
                  child: Text(
                    'Ticket price is what guests pay for entry. '
                    'Your planning budget (Budget tab) is separate — '
                    'what you spend to organize the event.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gutter(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Ticket page',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: page.isPublished
                            ? AppColors.primary.withValues(alpha: 0.18)
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          page.isPublished ? 'Published' : 'Draft',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: page.isPublished
                                ? AppColors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gutter(),
                TextField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Page title',
                    prefixIcon: Icon(LucideIcons.ticket),
                  ),
                ),
                const Gutter(),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What’s included with the ticket…',
                    alignLabelWithHint: true,
                  ),
                ),
                const Gutter(),
                TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Ticket price (XAF)',
                    prefixIcon: Icon(LucideIcons.banknote),
                  ),
                ),
                const Gutter(),
                TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Tickets available',
                    prefixIcon: Icon(LucideIcons.hash),
                  ),
                ),
                const Gutter(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _save(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                    const GutterSmall(),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () => _save(publish: true),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          page.isPublished ? 'Update & publish' : 'Publish page',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (page.isConfigured) ...[
          const Gutter(),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const GutterSmall(),
                  Text(
                    page.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (page.description.isNotEmpty) ...[
                    const GutterTiny(),
                    Text(
                      page.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const Gutter(),
                  Row(
                    children: [
                      Text(
                        formatEventMoney(page.price),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${page.quantity} tickets',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
