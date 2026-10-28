import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/core/configs/theme/app_theme.dart';
import 'package:vms/core/utils/validators.dart';
import 'package:vms/core/widgets/custom_text_field.dart';
import 'package:vms/core/widgets/registration_success_dialog.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';
import 'package:vms/features/dashboard/viewmodels/dashboard_view_model.dart';

class VisitorFormScreen extends StatefulWidget {
  final Visitor? existingVisitor;

  const VisitorFormScreen({super.key, this.existingVisitor});

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();

  String _selectedCategory = VisitorCategory.customer;
  String _selectedProject = 'Project A (Sumadhura Horizon)';
  // bool _printPhysicalPass = false;

  String? _nameError;
  String? _mobileError;
  String? _emailError;
  String? _purposeError;

  bool _hasAttemptedSubmit = false;
  bool _shouldAllowPop = false;

  final List<String> _projectOptions = [
    'Project A (Sumadhura Horizon)',
    'Project B (Sumadhura Infracon)',
    'Project C (Sumadhura Aspire)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingVisitor != null) {
      final v = widget.existingVisitor!;
      _nameCtrl.text = v.name;
      _mobileCtrl.text = v.mobile;
      _emailCtrl.text = v.email ?? '';
      _purposeCtrl.text = v.purpose;
      _selectedCategory = v.visitorType;
      _selectedProject = _projectOptions.contains(v.project)
          ? v.project
          : _projectOptions.first;
      // _printPhysicalPass = v.printPhysicalPass;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  void _validateAll() {
    setState(() {
      _nameError = AppValidators.validateName(_nameCtrl.text);
      _mobileError = AppValidators.validateMobile(_mobileCtrl.text);
      _emailError = AppValidators.validateEmail(_emailCtrl.text);
      _purposeError = AppValidators.validatePurpose(_purposeCtrl.text);
    });
  }

  bool get _isValid =>
      _nameError == null &&
      _mobileError == null &&
      _emailError == null &&
      _purposeError == null;

  bool get _hasUnsavedChanges {
    if (_shouldAllowPop) return false;
    if (widget.existingVisitor != null) {
      final v = widget.existingVisitor!;
      return _nameCtrl.text != v.name ||
          _mobileCtrl.text != v.mobile ||
          _emailCtrl.text != (v.email ?? '') ||
          _purposeCtrl.text != v.purpose ||
          _selectedCategory != v.visitorType ||
          _selectedProject != v.project;
    }
    return _nameCtrl.text.trim().isNotEmpty ||
        _mobileCtrl.text.trim().isNotEmpty ||
        _emailCtrl.text.trim().isNotEmpty ||
        _purposeCtrl.text.trim().isNotEmpty;
  }

  Future<void> _handleBackPress() async {
    if (!_hasUnsavedChanges) {
      Navigator.of(context).pop();
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Discard changes?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.navy,
          ),
        ),
        content: const Text(
          'You have unsaved entries in the visitor form. Are you sure you want to discard them?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Discard',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      setState(() {
        _shouldAllowPop = true;
      });
      Navigator.of(context).pop();
    }
  }

  void _saveVisitor() {
    setState(() {
      _hasAttemptedSubmit = true;
    });
    _validateAll();

    if (!_isValid) return;

    final vm = context.read<DashboardViewModel>();

    if (widget.existingVisitor != null) {
      final updated = widget.existingVisitor!.copyWith(
        name: _nameCtrl.text.trim(),
        mobile: _mobileCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        visitorType: _selectedCategory,
        project: _selectedProject,
        purpose: _purposeCtrl.text.trim(),
        // printPhysicalPass: _printPhysicalPass,
      );
      vm.updateVisitor(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${updated.name} updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _shouldAllowPop = true);
      Navigator.of(context).pop();
    } else {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final year = DateTime.now().year;
      final passNumber = 'SUM-$year-${(vm.totalVisitorsCount + 1).toString().padLeft(3, '0')}';
      final newVisitor = Visitor(
        id: newId,
        name: _nameCtrl.text.trim(),
        mobile: _mobileCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        visitorType: _selectedCategory,
        project: _selectedProject,
        purpose: _purposeCtrl.text.trim(),
        status: VisitorStatus.registered,
        createdAt: DateTime.now().toIso8601String(),
        passNumber: passNumber,
        // printPhysicalPass: _printPhysicalPass,
      );
      vm.registerVisitor(newVisitor);

      // Display confirmation container showing QR and sharing options
      RegistrationSuccessDialog.show(
        context,
        visitor: newVisitor,
        onClose: () {
          setState(() => _shouldAllowPop = true);
          Navigator.of(context).pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingVisitor != null;

    return PopScope(
      canPop:false ,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        // appBar: const AppHeader(title: 'Dashboard'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subheader Row: Back Arrow + Title + Refresh + Help
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.navy),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32),
                      onPressed: _handleBackPress,
                    ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Visitor' : 'Register Visitor',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Text(
                            '• FRONT-DESK • QUICK ENTRY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB45309),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
                    onPressed: () {
                      _nameCtrl.clear();
                      _mobileCtrl.clear();
                      _emailCtrl.clear();
                      _purposeCtrl.clear();
                      setState(() {
                        _hasAttemptedSubmit = false;
                        _nameError = null;
                        _mobileError = null;
                        _emailError = null;
                        _purposeError = null;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF64748B)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Quick Entry Guide'),
                          content: const Text(
                            'Fill in mandatory visitor details (*), choose a category, and specify purpose to issue an express gate entry pass.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Got it'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
        
              // Incomplete Entry Details Banner (shown when validation fails)
              if (_hasAttemptedSubmit && !_isValid) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Incomplete Entry Details',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Please correct the highlighted fields before generating gate clearance badge.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF991B1B),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
        
              // 1. Visitor Full Name
              CustomTextField(
                label: 'Visitor Full Name *',
                badgeText: 'Required',
                badgeColor: _nameError != null ? const Color(0xFFDC2626) : const Color(0xFFB91C1C),
                controller: _nameCtrl,
                hintText: 'e.g. Ramesh Kumar',
                prefixIcon: Icons.person_outline_rounded,
                errorText: _nameError,
                onChanged: (val) {
                  if (_hasAttemptedSubmit) {
                    setState(() => _nameError = AppValidators.validateName(val));
                  }
                },
              ),
              const SizedBox(height: 14),
        
              // 2. Mobile Number
              CustomTextField(
                label: 'Mobile Number *',
                badgeText: '10 digits',
                controller: _mobileCtrl,
                hintText: '9876543210',
                keyboardType: TextInputType.phone,
                prefixWidget: Container(
                  margin: const EdgeInsets.only(left: 8, right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'IN +91',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.navy,
                    ),
                  ),
                ),
                errorText: _mobileError,
                onChanged: (val) {
                  if (_hasAttemptedSubmit) {
                    setState(() => _mobileError = AppValidators.validateMobile(val));
                  }
                },
              ),
              const SizedBox(height: 14),
        
              // 3. Email Address
              CustomTextField(
                label: 'Email Address',
                badgeText: 'Optional',
                controller: _emailCtrl,
                hintText: 'e.g. visitor@company.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                helperText: 'Used to dispatch e-receipt pass and gate entry QR code.',
                onChanged: (val) {
                  if (_hasAttemptedSubmit) {
                    setState(() => _emailError = AppValidators.validateEmail(val));
                  }
                },
              ),
              const SizedBox(height: 16),
        
              // 4. Visitor Category
              const Text(
                'Visitor Category *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _CategorySelectorTile(
                      label: 'Customer',
                      icon: Icons.badge_outlined,
                      isSelected: _selectedCategory == VisitorCategory.customer,
                      onTap: () => setState(() => _selectedCategory = VisitorCategory.customer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CategorySelectorTile(
                      label: 'Vendor',
                      icon: Icons.local_shipping_outlined,
                      isSelected: _selectedCategory == VisitorCategory.vendor,
                      onTap: () => setState(() => _selectedCategory = VisitorCategory.vendor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CategorySelectorTile(
                      label: 'Other',
                      icon: Icons.more_horiz_rounded,
                      isSelected: _selectedCategory == VisitorCategory.other,
                      onTap: () => setState(() => _selectedCategory = VisitorCategory.other),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
        
              // 5. Select Project / Estate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Select Project / Estate *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.navy,
                    ),
                  ),
                  Text(
                    'Active Premises',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProject,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                    items: _projectOptions.map((proj) {
                      return DropdownMenuItem(
                        value: proj,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              size: 18,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                proj,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.navy,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedProject = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
        
              // 6. Purpose of Visit
              CustomTextField(
                label: 'Purpose of Visit *',
                badgeText: 'Max 120 chars',
                controller: _purposeCtrl,
                hintText: 'e.g. Site Visit, Flat Booking Discussion, Maintenance Check',
                maxLines: 3,
                errorText: _purposeError,
                onChanged: (val) {
                  if (_hasAttemptedSubmit) {
                    setState(() => _purposeError = AppValidators.validatePurpose(val));
                  }
                },
              ),
              const SizedBox(height: 8),
              // Quick Suggestion Pills
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _SuggestionPill(
                    label: '+ Site Tour',
                    onTap: () => setState(() => _purposeCtrl.text = 'Site Tour'),
                  ),
                  _SuggestionPill(
                    label: '+ Flat Booking',
                    onTap: () => setState(() => _purposeCtrl.text = 'Flat Booking Discussion'),
                  ),
                  _SuggestionPill(
                    label: '+ Vendor Delivery',
                    onTap: () => setState(() => _purposeCtrl.text = 'Material / Vendor Delivery'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
        
              // 7. Print Physical Pass Switch Tile
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFEFF6FF),
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: const Color(0xFFDBEAFE)),
              //   ),
              //   child: Row(
              //     children: [
              //       Container(
              //         width: 36,
              //         height: 36,
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           borderRadius: BorderRadius.circular(8),
              //         ),
              //         child: const Icon(
              //           Icons.badge_outlined,
              //           color: Color(0xFF2563EB),
              //           size: 20,
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       const Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'Print Physical Pass',
              //               style: TextStyle(
              //                 fontSize: 13,
              //                 fontWeight: FontWeight.w700,
              //                 color: AppTheme.navy,
              //               ),
              //             ),
              //             Text(
              //               'Direct dispatch to thermal desk printer',
              //               style: TextStyle(
              //                 fontSize: 11,
              //                 color: Color(0xFF64748B),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       Switch(
              //         value: _printPhysicalPass,
              //         activeColor: AppTheme.navy,
              //         onChanged: (val) => setState(() => _printPhysicalPass = val),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 24),
        
              // Bottom Action Buttons: CANCEL & SAVE VISITOR
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _handleBackPress,
                        icon: const Icon(Icons.close, size: 18, color: AppTheme.navy),
                        label: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppTheme.navy,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _saveVisitor,
                        icon: const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.navy),
                        label: Text(
                          isEditing ? 'UPDATE' : 'SAVE VISITOR',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppTheme.navy,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _CategorySelectorTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategorySelectorTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.navy : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.navy : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.gold : const Color(0xFF64748B),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDBEAFE)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}
