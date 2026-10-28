import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vms/core/configs/theme/app_theme.dart';
import 'package:vms/core/widgets/app_header.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';
import 'package:vms/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:vms/features/dashboard/views/visitor_detail_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  bool _hasScanned = false;
  bool _isTorchOn = false;
  bool _isPermissionGranted = false;
  bool _isPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      autoStart: false,
    );
    _checkAndRequestPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permission if user returned from system settings
      _checkPermissionStatusOnly();
    }
  }

  Future<void> _checkPermissionStatusOnly() async {
    final status = await Permission.camera.status;
    setState(() {
      _isPermissionGranted = status.isGranted;
      _isPermanentlyDenied = status.isPermanentlyDenied;
    });
    if (status.isGranted) {
      _controller.start();
    }
  }

  Future<void> _checkAndRequestPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
      _controller.start();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isPermissionGranted = false;
        _isPermanentlyDenied = true;
      });
    } else {
      // Request permission directly from system
      final result = await Permission.camera.request();
      setState(() {
        _isPermissionGranted = result.isGranted;
        _isPermanentlyDenied = result.isPermanentlyDenied;
      });
      if (result.isGranted) {
        _controller.start();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue?.trim();
    if (code == null || code.isEmpty) return;

    debugPrint('Optical Scanner detected code: $code');

    final vm = context.read<DashboardViewModel>();

    // Resilient matching against passNumber, formattedPassNumber, ID, mobile, or name
    final matched = vm.allVisitors.cast<Visitor?>().firstWhere(
      (v) {
        if (v == null) return false;
        final passClean = v.formattedPassNumber.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
        final codeClean = code.toLowerCase().replaceAll('-', '').replaceAll(' ', '');

        return v.passNumber?.toLowerCase() == code.toLowerCase() ||
            v.formattedPassNumber.toLowerCase() == code.toLowerCase() ||
            passClean == codeClean ||
            v.id == code ||
            v.mobile == code ||
            code.toLowerCase().contains(v.name.toLowerCase());
      },
      orElse: () => null,
    );

    setState(() => _hasScanned = true);

    if (matched != null) {
      _showScanSuccess(matched);
    } else {
      _showScanNotFound(code);
    }
  }

  void _showScanSuccess(Visitor initialVisitor) {
    bool navigatedToDetails = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<DashboardViewModel>(
          builder: (context, vm, _) {
            final visitor = vm.allVisitors.firstWhere(
              (v) => v.id == initialVisitor.id,
              orElse: () => initialVisitor,
            );

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pass Verified',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.navy,
                              ),
                            ),
                            Text(
                              'Pass #${visitor.formattedPassNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Visitor Name', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text(visitor.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Status', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text(
                              visitor.status,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: visitor.isCheckedIn
                                    ? const Color(0xFF16A34A)
                                    : visitor.isCheckedOut
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Premises', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text(visitor.project, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // LEFT BUTTON: View Details (replacing "Scan Another")
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            navigatedToDetails = true;
                            Navigator.of(ctx).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VisitorDetailScreen(visitor: visitor),
                              ),
                            ).then((_) {
                              if (mounted) setState(() => _hasScanned = false);
                            });
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 16, color: AppTheme.navy),
                          label: const Text(
                            'View Details',
                            style: TextStyle(
                              color: AppTheme.navy,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // RIGHT BUTTON: Status-based Action (Check In / Check Out)
                      Expanded(
                        child: visitor.canCheckIn
                            ? ElevatedButton.icon(
                                onPressed: () async {
                                  await vm.checkInVisitor(visitor.id);
                                  if (ctx.mounted) {
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${visitor.name} checked in successfully!'),
                                        backgroundColor: const Color(0xFF16A34A),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.login_rounded, color: Colors.white, size: 18),
                                label: const Text(
                                  'Check In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              )
                            : visitor.canCheckOut
                                ? ElevatedButton.icon(
                                    onPressed: () async {
                                      await vm.checkOutVisitor(visitor.id);
                                      if (ctx.mounted) {
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${visitor.name} checked out successfully!'),
                                            backgroundColor: const Color(0xFF0F172A),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                                    label: const Text(
                                      'Check Out',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF16A34A),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.done_all, size: 18),
                                    label: const Text(
                                      'Completed',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (!navigatedToDetails && mounted) {
        setState(() => _hasScanned = false);
      }
    });
  }

  void _showScanNotFound(String rawCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unrecognized Pass'),
        content: Text('No visitor found matching code: "$rawCode". Please check registration or register as a walk-in.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() => _hasScanned = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppHeader(
        title: 'Gate Pass Scanner',
        actions: [
          if (_isPermissionGranted) ...[
            // Torch toggle
            IconButton(
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: _isTorchOn ? AppTheme.gold : Colors.white,
              ),
              onPressed: () async {
                await _controller.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              },
            ),
            // Flip camera
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: () => _controller.switchCamera(),
            ),
          ],
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          // If checking permission or permission not yet granted, show permission request UI
          if (!_isPermissionGranted) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.gold, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: AppTheme.gold,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Camera Permission Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'To scan visitor entry passes and verify optical QR codes, please allow camera access on this device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Primary Action Button (Request or Open Settings)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isPermanentlyDenied
                            ? openAppSettings
                            : _checkAndRequestPermission,
                        icon: Icon(
                          _isPermanentlyDenied
                              ? Icons.settings_outlined
                              : Icons.check_circle_outline,
                          color: AppTheme.navy,
                          size: 20,
                        ),
                        label: Text(
                          _isPermanentlyDenied
                              ? 'Open App Settings'
                              : 'Enable Camera Permission',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navy,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Quick Test Option for Emulators
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Or Test Pass Scenarios Directly:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: vm.allVisitors.take(3).map((visitor) {
                              return ActionChip(
                                label: Text('Scan ${visitor.name}'),
                                backgroundColor: const Color(0xFF0F172A),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                side: const BorderSide(color: Color(0xFF475569)),
                                onPressed: () => _showScanSuccess(visitor),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Permission is granted: Render live camera feed and viewfinder
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: MobileScanner(
                  controller: _controller,
                  fit: BoxFit.cover,
                  onDetect: _onDetect,
                ),
              ),

              // Viewfinder & Instructions Overlay
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Optical QR Verification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Align guest pass QR code within the frame to verify clearance and log entry.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Viewfinder Frame
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.gold, width: 2.5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 210,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppTheme.gold,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.gold.withValues(alpha: 0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quick test shortcuts
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_outlined, size: 16, color: AppTheme.gold),
                            SizedBox(width: 6),
                            Text(
                              'Simulator Quick Test:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: vm.allVisitors.take(3).map((visitor) {
                            return ActionChip(
                              label: Text('Scan ${visitor.name}'),
                              backgroundColor: const Color(0xFF0F172A),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              side: const BorderSide(color: Color(0xFF475569)),
                              onPressed: () => _showScanSuccess(visitor),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
