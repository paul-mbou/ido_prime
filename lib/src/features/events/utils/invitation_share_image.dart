import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/models/event_invitation.dart';
import 'package:ido_prime/src/features/events/widgets/invitation_card_preview.dart';

/// Full share canvas: invitation design + RSVP link underneath.
class InvitationShareImage extends StatelessWidget {
  const InvitationShareImage({
    super.key,
    required this.event,
    this.width = 390,
  });

  final Event event;
  final double width;

  @override
  Widget build(BuildContext context) {
    final invitation = event.invitation;
    final link = eventInviteLink(event.id);
    final isLight = invitation.cardStyle == InvitationCardStyle.softLavender;
    final canvas = isLight ? const Color(0xFFF4F1F9) : const Color(0xFF1A0F2F);
    final linkColor = isLight ? AppColors.onPrimary : const Color(0xFFF4F1F9);
    final muted = isLight ? AppColors.lightMuted : const Color(0xFF89809C);

    return Material(
      color: canvas,
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InvitationCardPreview(event: event),
              const GutterLarge(),
              Text(
                'RSVP on IDO',
                style: TextStyle(
                  color: muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
              const GutterTiny(),
              Text(
                link,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              const Gutter(),
              Text(
                'Powered by IDO',
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders [InvitationShareImage] off-screen and returns a PNG temp file.
Future<File> buildInvitationSharePng(
  BuildContext context,
  Event event, {
  double logicalWidth = 390,
  double pixelRatio = 3,
}) async {
  final key = GlobalKey();
  final overlay = Overlay.of(context, rootOverlay: true);

  final entry = OverlayEntry(
    builder: (ctx) {
      return IgnorePointer(
        child: Opacity(
          opacity: 0.01,
          child: Align(
            alignment: Alignment.topLeft,
            child: OverflowBox(
              minWidth: 0,
              maxWidth: logicalWidth,
              minHeight: 0,
              maxHeight: double.infinity,
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: key,
                child: InvitationShareImage(event: event, width: logicalWidth),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  try {
    await Future<void>.delayed(const Duration(milliseconds: 16));
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 32));
    await WidgetsBinding.instance.endOfFrame;

    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('Could not find invitation share render boundary');
    }

    // Ensure layout completed with non-zero size.
    if (boundary.size.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode invitation PNG');
    }

    final file = File(
      '${Directory.systemTemp.path}/ido_invite_${event.id}_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return file;
  } finally {
    entry.remove();
  }
}
