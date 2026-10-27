class VisitorStatus {
  VisitorStatus._();

  static const String registered = 'Registered';
  static const String checkedIn = 'Checked In';
  static const String checkedOut = 'Checked Out';
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
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: _nullIfEmpty(json['email']),
      visitorType: json['visitor_type']?.toString() ?? '',
      project: json['project']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? VisitorStatus.registered,
      createdAt: json['created_at']?.toString() ?? '',
      checkInTime: _nullIfEmpty(json['check_in_time']),
      checkOutTime: _nullIfEmpty(json['check_out_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

  static bool _isSameDay(DateTime? d, DateTime now) =>
      d != null && d.year == now.year && d.month == now.month && d.day == now.day;

  bool get isRegisteredToday => _isSameDay(createdDate, DateTime.now());
  bool get isCheckedOutToday => _isSameDay(checkOutDate, DateTime.now());

  static String? _nullIfEmpty(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}