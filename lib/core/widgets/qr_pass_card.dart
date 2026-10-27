import 'package:flutter/material.dart';
import 'package:vms/core/configs/theme/app_theme.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';

class QrPassCard extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final GlobalKey? qrKey;

  const QrPassCard({
    super.key,
    required this.visitor,
    required this.onShare,
    required this.onPrint,
    this.qrKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEFF4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: EXPRESS PASS | ID: #X
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: Color(0xFFB45309),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'EXPRESS PASS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navy,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ID: #${visitor.id.isEmpty ? '6' : visitor.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // QR Code vector box
          RepaintBoundary(
            key: qrKey,
            child: Container(
              width: 170,
              height: 170,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: CustomPaint(
                painter: _QrPainter(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Pass Number
          Text(
            visitor.formattedPassNumber,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.navy,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Present at Security Gate reader for\noptical verification & entry logging',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          // Buttons: Share e-Pass | Print Slip
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text(
                      'Share e-Pass',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.navy,
                      backgroundColor: const Color(0xFFEFF6FF),
                      side: const BorderSide(color: Color(0xFFDBEAFE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onPrint,
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text(
                      'Print Slip',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.navy,
                      backgroundColor: const Color(0xFFEFF6FF),
                      side: const BorderSide(color: Color(0xFFDBEAFE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()..color = const Color(0xFF1E293B);

    final w = size.width;
    final h = size.height;
    final unit = w / 21;

    // Corner Finder Patterns
    void drawFinder(double x, double y) {
      // Outer square (7x7)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 7 * unit, 7 * unit),
          Radius.circular(unit * 0.8),
        ),
        darkPaint,
      );
      // Inner white square (5x5)
      canvas.drawRect(
        Rect.fromLTWH(x + unit, y + unit, 5 * unit, 5 * unit),
        Paint()..color = Colors.white,
      );
      // Center dark square (3x3)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 2 * unit, y + 2 * unit, 3 * unit, 3 * unit),
          Radius.circular(unit * 0.4),
        ),
        darkPaint,
      );
    }

    // Top-Left Finder
    drawFinder(0, 0);
    // Top-Right Finder
    drawFinder(w - 7 * unit, 0);
    // Bottom-Left Finder
    drawFinder(0, h - 7 * unit);

    // Decorative Data Dots Grid
    final dotPositions = [
      // row 1-3
      [8, 1], [10, 1], [12, 1],
      [9, 2], [11, 3],
      // center
      [8, 7], [12, 7],
      [7, 9], [8, 9], [12, 9], [13, 9],
      [7, 11], [13, 11],
      [8, 13], [12, 13],
      // right
      [15, 8], [17, 8], [19, 8],
      [14, 10], [16, 10], [18, 10], [20, 10],
      [15, 12], [17, 12], [19, 12],
      // bottom
      [8, 15], [10, 15], [14, 15], [16, 15], [18, 15],
      [9, 17], [11, 17], [15, 17], [17, 17], [19, 17],
      [8, 19], [10, 19], [14, 19], [16, 19],
    ];

    for (final pos in dotPositions) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pos[0] * unit, pos[1] * unit, unit * 0.9, unit * 0.9),
          Radius.circular(unit * 0.2),
        ),
        darkPaint,
      );
    }

    // Center Gold Sumadhura Diamond Emblem
    final center = Offset(w / 2, h / 2);
    final emblemSize = unit * 3.6;

    // White backing circle
    canvas.drawCircle(center, emblemSize * 0.75, Paint()..color = Colors.white);

    // Gold diamond
    final goldPaint = Paint()..color = const Color(0xFFF7C35F);
    final diamondPath = Path()
      ..moveTo(center.dx, center.dy - emblemSize / 2)
      ..lineTo(center.dx + emblemSize / 2, center.dy)
      ..lineTo(center.dx, center.dy + emblemSize / 2)
      ..lineTo(center.dx - emblemSize / 2, center.dy)
      ..close();
    canvas.drawPath(diamondPath, goldPaint);

    // Inner icon symbol
    final innerPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final innerPath = Path()
      ..moveTo(center.dx - 3, center.dy - 1)
      ..lineTo(center.dx, center.dy - 4)
      ..lineTo(center.dx + 3, center.dy - 1)
      ..moveTo(center.dx - 3, center.dy + 1)
      ..lineTo(center.dx, center.dy + 4)
      ..lineTo(center.dx + 3, center.dy + 1);
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
