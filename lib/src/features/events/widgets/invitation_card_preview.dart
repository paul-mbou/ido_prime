import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/models/event_invitation.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Preview of the shareable invitation card (IDO brand styles).
class InvitationCardPreview extends StatelessWidget {
  const InvitationCardPreview({
    super.key,
    required this.event,
    this.style,
    this.headline,
    this.message,
  });

  final Event event;
  final InvitationCardStyle? style;
  final String? headline;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final invitation = event.invitation;
    final cardStyle = style ?? invitation.cardStyle;
    final title = (headline ?? invitation.headline).trim().isEmpty
        ? event.title
        : (headline ?? invitation.headline).trim();
    final body = (message ?? invitation.message).trim();
    final palette = _palette(cardStyle);

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette.gradient,
          ),
          border: Border.all(color: palette.border, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -40,
                right: -30,
                child: _Orb(color: palette.orb, size: 140),
              ),
              Positioned(
                bottom: -50,
                left: -40,
                child: _Orb(
                  color: palette.orb.withValues(alpha: 0.35),
                  size: 160,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      "You're invited",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const GutterSmall(),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        height: 1.15,
                      ),
                    ),
                    const Gutter(),
                    _MetaLine(
                      icon: LucideIcons.calendarDays,
                      label: event.dateLabel,
                      color: palette.ink,
                      muted: palette.muted,
                    ),
                    const GutterTiny(),
                    _MetaLine(
                      icon: LucideIcons.mapPin,
                      label: event.place,
                      color: palette.ink,
                      muted: palette.muted,
                    ),
                    if (event.hostName.isNotEmpty) ...[
                      const GutterTiny(),
                      _MetaLine(
                        icon: LucideIcons.user,
                        label: 'Hosted by ${event.hostName}',
                        color: palette.ink,
                        muted: palette.muted,
                      ),
                    ],
                    const Gutter(),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.muted,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: palette.accent.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          'Open link to RSVP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
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

  _CardPalette _palette(InvitationCardStyle style) => switch (style) {
    InvitationCardStyle.classicGold => const _CardPalette(
      gradient: [Color(0xFF2A1F18), Color(0xFF1A0F2F), Color(0xFF3D3010)],
      ink: Color(0xFFFFF8E7),
      muted: Color(0xFFE8D9B0),
      accent: AppColors.primary,
      border: AppColors.primary,
      orb: Color(0x66D3AF35),
    ),
    InvitationCardStyle.midnightGarden => const _CardPalette(
      gradient: [Color(0xFF1A0F2F), Color(0xFF241939), Color(0xFF0F2A22)],
      ink: Color(0xFFF4F1F9),
      muted: Color(0xFFB8AFC9),
      accent: AppColors.primary,
      border: Color(0xFF9B8FB8),
      orb: Color(0x449B8FB8),
    ),
    InvitationCardStyle.softLavender => const _CardPalette(
      gradient: [Color(0xFFF4F1F9), Color(0xFFE9E3F2), Color(0xFFF5EDD0)],
      ink: AppColors.onPrimary,
      muted: AppColors.lightMuted,
      accent: Color(0xFF5C4D7A),
      border: AppColors.primary,
      orb: Color(0x33D3AF35),
    ),
  };
}

class _CardPalette {
  const _CardPalette({
    required this.gradient,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.border,
    required this.orb,
  });

  final List<Color> gradient;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color border;
  final Color orb;
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.label,
    required this.color,
    required this.muted,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: muted),
        const GutterTiny(),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
