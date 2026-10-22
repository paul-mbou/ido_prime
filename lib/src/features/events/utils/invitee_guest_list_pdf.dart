import 'dart:typed_data';

import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/models/event_invitation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds a printable guest list PDF for accepted invitees.
Future<Uint8List> buildAcceptedInviteesPdf(Event event) async {
  final accepted =
      event.invitation.invitees
          .where((i) => i.status == InviteeStatus.accepted)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  final gold = PdfColor.fromInt(0xFFD3AF35);
  final ink = PdfColor.fromInt(0xFF1A0F2F);
  final muted = PdfColor.fromInt(0xFF6E6682);
  final line = PdfColor.fromInt(0xFFD2CBE0);
  final soft = PdfColor.fromInt(0xFFF4F1F9);

  final doc = pw.Document(
    title: '${event.title} — Guest list',
    author: 'IDO Prime',
  );

  final generated = DateFormat('MMM d, yyyy · HH:mm').format(DateTime.now());
  final headcount = event.invitation.acceptedHeadcount;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 48, 40, 48),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: soft,
              borderRadius: pw.BorderRadius.circular(14),
              border: pw.Border.all(color: gold, width: 1.2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'IDO',
                  style: pw.TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  event.title,
                  style: pw.TextStyle(
                    color: ink,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Accepted guest list',
                  style: pw.TextStyle(color: muted, fontSize: 12),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Text(
                      event.dateLabel,
                      style: pw.TextStyle(color: ink, fontSize: 11),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text('·', style: pw.TextStyle(color: muted)),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Text(
                        event.place,
                        style: pw.TextStyle(color: ink, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${accepted.length} guests · $headcount seats (incl. +1s)',
                style: pw.TextStyle(
                  color: ink,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Generated $generated',
                style: pw.TextStyle(color: muted, fontSize: 9),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(height: 1, color: line),
          pw.SizedBox(height: 12),
        ],
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 12),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(color: muted, fontSize: 9),
        ),
      ),
      build: (context) {
        if (accepted.isEmpty) {
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 40),
              child: pw.Center(
                child: pw.Text(
                  'No accepted guests yet.',
                  style: pw.TextStyle(color: muted, fontSize: 13),
                ),
              ),
            ),
          ];
        }

        return [
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: line, width: 0.6),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2.4),
              2: const pw.FlexColumnWidth(2.2),
              3: const pw.FlexColumnWidth(0.7),
              4: const pw.FlexColumnWidth(1.4),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: soft),
                children: [
                  _cell('#', bold: true),
                  _cell('Name', bold: true),
                  _cell('Email', bold: true),
                  _cell('+1s', bold: true),
                  _cell('Note', bold: true),
                ],
              ),
              for (var i = 0; i < accepted.length; i++)
                pw.TableRow(
                  children: [
                    _cell('${i + 1}'),
                    _cell(accepted[i].name, bold: true),
                    _cell(accepted[i].email.isEmpty ? '—' : accepted[i].email),
                    _cell('${accepted[i].plusOnes}'),
                    _cell(accepted[i].note.isEmpty ? '—' : accepted[i].note),
                  ],
                ),
            ],
          ),
        ];
      },
    ),
  );

  return doc.save();
}

pw.Widget _cell(String text, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: PdfColor.fromInt(0xFF1A0F2F),
      ),
    ),
  );
}
