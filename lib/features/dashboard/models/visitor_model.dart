class VisitorStatus {
  VisitorStatus._();

  static const String registered = 'Registered';
  static const String checkedIn = 'Checked In';
  static const String checkedOut = 'Checked Out';
}

class VisitorCategory {
  VisitorCategory._();

  static const String customer = 'Customer';
  static const String vendor = 'Vendor';
  static const String other = 'Other';

  static const List<String> all = [customer, vendor, other];
}

class Visitor {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
  final String status;
  final String createdAt;
  final String? checkInTime;
  final String? checkOutTime;
  final String? passNumber;
  final String? unit;
  final bool printPhysicalPass;

  const Visitor({
    this.id = '',
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    this.status = VisitorStatus.registered,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
    this.passNumber,
    this.unit,
    this.printPhysicalPass = false,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: _nullIfEmpty(json['email']),
      visitorType: json['visitor_type']?.toString() ??
          json['visitorType']?.toString() ??
          VisitorCategory.customer,
      project: json['project']?.toString() ?? 'Project A (Sumadhura Horizon)',
      purpose: json['purpose']?.toString() ?? 'Site Visit',
      status: json['status']?.toString() ?? VisitorStatus.registered,
      createdAt: json['created_at']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      checkInTime: _nullIfEmpty(json['check_in_time'] ?? json['checkInTime']),
      checkOutTime: _nullIfEmpty(json['check_out_time'] ?? json['checkOutTime']),
      passNumber: _nullIfEmpty(json['pass_number'] ?? json['passNumber']),
      unit: _nullIfEmpty(json['unit']),
      printPhysicalPass: json['print_physical_pass'] == true ||
          json['printPhysicalPass'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      'status': status,
      'created_at': createdAt,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'pass_number': passNumber,
      'unit': unit,
      'print_physical_pass': printPhysicalPass,
    };
  }

  static Map<String, dynamic> checkInPatch(DateTime now) => {
        'status': VisitorStatus.checkedIn,
        'check_in_time': now.toIso8601String(),
      };

  static Map<String, dynamic> checkOutPatch(DateTime now) => {
        'status': VisitorStatus.checkedOut,
        'check_out_time': now.toIso8601String(),
      };

  Visitor copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? visitorType,
    String? project,
    String? purpose,
    String? status,
    String? createdAt,
    String? checkInTime,
    String? checkOutTime,
    String? passNumber,
    String? unit,
    bool? printPhysicalPass,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      visitorType: visitorType ?? this.visitorType,
      project: project ?? this.project,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      passNumber: passNumber ?? this.passNumber,
      unit: unit ?? this.unit,
      printPhysicalPass: printPhysicalPass ?? this.printPhysicalPass,
    );
  }

  bool get isRegistered => status == VisitorStatus.registered;
  bool get isCheckedIn => status == VisitorStatus.checkedIn;
  bool get isCheckedOut => status == VisitorStatus.checkedOut;

  bool get canCheckIn => isRegistered;
  bool get canCheckOut => isCheckedIn;

  DateTime? get createdDate => DateTime.tryParse(createdAt)?.toLocal();
  DateTime? get checkInDate =>
      checkInTime == null ? null : DateTime.tryParse(checkInTime!)?.toLocal();
  DateTime? get checkOutDate =>
      checkOutTime == null ? null : DateTime.tryParse(checkOutTime!)?.toLocal();

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'V';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get formattedPassNumber {
    if (passNumber != null && passNumber!.isNotEmpty) return passNumber!;
    final numId = int.tryParse(id) ?? 1;
    return 'SUM-2024-${numId.toString().padLeft(3, '0')}';
  }

  static String? _nullIfEmpty(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}
