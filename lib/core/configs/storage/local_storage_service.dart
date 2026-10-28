import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';

class LocalStorageService {
  static const String _visitorsKey = 'cached_visitors_v1';
  static const String _pendingDeletesKey = 'pending_deleted_ids_v1';

 
  /// Read cached visitors from SharedPreferences
  Future<List<Visitor>> getCachedVisitors() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_visitorsKey);

    if (jsonString == null || jsonString.trim().isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => Visitor.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
     
      return [];
    }
  }

  /// Save visitors list to SharedPreferences
  Future<bool> saveVisitors(List<Visitor> visitors) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = visitors.map((v) => v.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    return await prefs.setString(_visitorsKey, jsonString);
  }

  /// Clear the cached visitors (useful for sign out, reset, or testing)
  Future<bool> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_visitorsKey);
  }
   /// Read list of IDs deleted offline waiting for server sync
  Future<List<String>> getPendingDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pendingDeletesKey) ?? [];
  }

  /// Record an ID deleted offline
  Future<bool> addPendingDeletedId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingDeletesKey) ?? [];
    if (!list.contains(id)) {
      list.add(id);
      return prefs.setStringList(_pendingDeletesKey, list);
    }
    return true;
  }

  /// Remove ID once successfully deleted on the server
  Future<bool> removePendingDeletedId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingDeletesKey) ?? [];
    if (list.remove(id)) {
      return prefs.setStringList(_pendingDeletesKey, list);
    }
    return true;
  }
}
