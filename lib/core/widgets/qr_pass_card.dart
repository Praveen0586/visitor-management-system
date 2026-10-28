import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
                children: const [
                  Icon(
                    Icons.verified_outlined,
                    color: Color(0xFFB45309),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
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

          // Real, Standard ISO Scannable QR Code wrapped with RepaintBoundary for Sharing
          RepaintBoundary(
            key: qrKey,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  QrImageView(
                    data: visitor.formattedPassNumber,
                    version: QrVersions.auto,
                    size: 160.0,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF1E293B),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  // Center Gold Emblem (matching Screenshot 5)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppTheme.gold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.unfold_more_rounded,
                          size: 16,
                          color: AppTheme.navy,
                        ),
                      ),
                    ),
                  ),
                ],
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
              // const SizedBox(width: 12),
              // Expanded(
              //   child: SizedBox(
              //     height: 42,
              //     child: OutlinedButton.icon(
              //       onPressed: onPrint,
              //       icon: const Icon(Icons.print_outlined, size: 16),
              //       label: const Text(
              //         'Print Slip',
              //         style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              //       ),
              //       style: OutlinedButton.styleFrom(
              //         foregroundColor: AppTheme.navy,
              //         backgroundColor: const Color(0xFFEFF6FF),
              //         side: const BorderSide(color: Color(0xFFDBEAFE)),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(8),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
