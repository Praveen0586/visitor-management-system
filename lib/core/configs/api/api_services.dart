import 'package:dio/dio.dart';
import 'package:vms/core/configs/api/api_endpoints.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';

class ApiServices {
  final Dio _dio;

  ApiServices({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  /// Fetch all visitors from the MockAPI backend
  Future<List<Visitor>> getAllVisitors() async {
    final response = await _dio.get(ApiEndpoints.getAllVisitors);
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data
            .map((json) => Visitor.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Create a new visitor on the remote backend
  Future<Visitor> createVisitor(Visitor visitor) async {
    final response = await _dio.post(
      ApiEndpoints.createVisitor,
      data: visitor.toJson(),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Visitor.fromJson(response.data as Map<String, dynamic>);
    }
    return visitor;
  }

  /// Update an existing visitor on the remote backend
  Future<Visitor> updateVisitor(Visitor visitor) async {
    final response = await _dio.put(
      ApiEndpoints.updateVisitor(visitor.id),
      data: visitor.toJson(),
    );
    if (response.statusCode == 200) {
      return Visitor.fromJson(response.data as Map<String, dynamic>);
    }
    return visitor;
  }

  /// Patch visitor status (Check-In or Check-Out)
  Future<Visitor> patchVisitorStatus(
    String id,
    String newStatus, {
    DateTime? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now();
    final patchData = newStatus == VisitorStatus.checkedIn
        ? Visitor.checkInPatch(now)
        : Visitor.checkOutPatch(now);

    final response = await _dio.put(
      ApiEndpoints.patchVisitor(id),
      data: patchData,
    );

    if (response.statusCode == 200) {
      return Visitor.fromJson(response.data as Map<String, dynamic>);
    }

    return Visitor(
      id: id,
      name: '',
      mobile: '',
      visitorType: VisitorCategory.customer,
      project: '',
      purpose: '',
      status: newStatus,
      createdAt: now.toIso8601String(),
      checkInTime: newStatus == VisitorStatus.checkedIn ? now.toIso8601String() : null,
      checkOutTime: newStatus == VisitorStatus.checkedOut ? now.toIso8601String() : null,
    );
  }

  /// Delete visitor on remote backend
  Future<bool> deleteVisitor(String id) async {
    final response = await _dio.delete(ApiEndpoints.deleteVisitor(id));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
