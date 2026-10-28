import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';

class ShareService {
  ShareService._();

  /// Captures the QR pass widget from RepaintBoundary and shares as an image to WhatsApp / other apps
  static Future<void> sharePassWithQr({
    required GlobalKey qrKey,
    required Visitor visitor,
    Rect? sharePositionOrigin,
  }) async {
    final text = '🏢 *Sumadhura Group - Visitor Express Pass*\n'
        '👤 Guest: ${visitor.name}\n'
        '🎫 Pass ID: #${visitor.formattedPassNumber}\n'
        '📍 Premises: ${visitor.project}\n'
        '🎯 Purpose: ${visitor.purpose}\n'
        '📱 Mobile: +91 ${visitor.mobile}\n'
        '🛡️ Entry: Main Gate • Tower A\n\n'
        'Please present this digital pass QR code at the Security Barrier reader for entry clearance.';

    try {
      final boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/pass_${visitor.formattedPassNumber}.png';
          final file = File(filePath);
          await file.writeAsBytes(pngBytes);

          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'image/png', name: 'pass_${visitor.formattedPassNumber}.png')],
            text: text,
            subject: 'Visitor Express Pass - ${visitor.name}',
            sharePositionOrigin: sharePositionOrigin,
          );
          return;
        }
      }
    } catch (_) {
      // Fallback to text share if image rendering fails
    }

    // Text fallback
    await Share.share(
      text,
      subject: 'Visitor Express Pass - ${visitor.name}',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
