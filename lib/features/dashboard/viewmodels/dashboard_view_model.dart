import 'package:flutter/material.dart';
import 'package:vms/core/configs/api/api_services.dart';
import 'package:vms/core/configs/storage/local_storage_service.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';

enum ViewStatus { initial, loading, success, error }

class DashboardViewModel extends ChangeNotifier {
  final ApiServices _apiServices;
  final LocalStorageService _storageService;

  DashboardViewModel({
    ApiServices? apiServices,
    LocalStorageService? storageService,
    bool autoFetch = true,
  })  : _apiServices = apiServices ?? ApiServices(),
        _storageService = storageService ?? LocalStorageService() {
    if (autoFetch) {
      init();
    }
  }

  // ──────────────────────── STATE ────────────────────────
  List<Visitor> _visitors = [];
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Checked In', 'Registered', 'Checked Out'
  int _currentNavIndex = 0; // 0: Dashboard, 1: Visitors, 2: Scan
  DateTime _lastSyncTime = DateTime.now();

  // ──────────────────────── GETTERS ────────────────────────
  List<Visitor> get allVisitors => List.unmodifiable(_visitors);
  ViewStatus get status => _status;
  bool get isLoading => _status == ViewStatus.loading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  int get currentNavIndex => _currentNavIndex;
  DateTime get lastSyncTime => _lastSyncTime;

  /// Filtered visitors by status and search query
  List<Visitor> get filteredVisitors {
    return _visitors.where((visitor) {
      // 1. Status Filter
      if (_selectedFilter != 'All' && visitor.status != _selectedFilter) {
        return false;
      }
      // 2. Search Query (name or mobile)
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchesName = visitor.name.toLowerCase().contains(query);
        final matchesMobile = visitor.mobile.contains(query);
        return matchesName || matchesMobile;
      }
      return true;
    }).toList();
  }

  /// Top 4 recent visitors for Dashboard preview
  List<Visitor> get recentVisitors {
    return _visitors.take(4).toList();
  }

  // ──────────────────────── KPIS ────────────────────────
  int get totalVisitorsCount => _visitors.length;

  int get currentlyCheckedInCount =>
      _visitors.where((v) => v.isCheckedIn).length;

  int get checkedOutCount =>
      _visitors.where((v) => v.isCheckedOut).length;

  int get registeredCount =>
      _visitors.where((v) => v.isRegistered).length;

  // ──────────────────────── ACTIONS ────────────────────────

  void setNavIndex(int index) {
    if (_currentNavIndex != index) {
      _currentNavIndex = index;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void clearFiltersAndSearch() {
    _searchQuery = '';
    _selectedFilter = 'All';
    notifyListeners();
  }

  /// Initialize: Cache-First strategy
  Future<void> init() async {
    // 1. Read from local storage first (instant paint)
    final cached = await _storageService.getCachedVisitors();
    if (cached.isNotEmpty) {
      _visitors = cached;
      _status = ViewStatus.success;
      notifyListeners();
    }

    // 2. Refresh from remote API in background
    await fetchVisitors();
  }

  /// Fetch from remote API and refresh local cache
  Future<void> fetchVisitors() async {
    if (_visitors.isEmpty) {
      _status = ViewStatus.loading;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final remoteVisitors = await _apiServices.getAllVisitors();
      if (remoteVisitors.isNotEmpty) {
        _visitors = remoteVisitors;
        await _storageService.saveVisitors(_visitors);
      }
      _status = ViewStatus.success;
      _lastSyncTime = DateTime.now();
    } catch (e) {
      // If offline but cache exists, remain in success state with cached data
      if (_visitors.isEmpty) {
        _status = ViewStatus.error;
        _errorMessage = 'Could not load visitors: $e';
      }
    } finally {
      notifyListeners();
    }
  }

  /// Check In visitor
  Future<bool> checkInVisitor(String id) async {
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index == -1) return false;

    final updated = _visitors[index].copyWith(
      status: VisitorStatus.checkedIn,
      checkInTime: DateTime.now().toIso8601String(),
    );

    _visitors[index] = updated;
    await _storageService.saveVisitors(_visitors);
    _lastSyncTime = DateTime.now();
    notifyListeners();

    try {
      await _apiServices.patchVisitorStatus(id, VisitorStatus.checkedIn);
    } catch (_) {
      // Retained in local cache
    }
    return true;
  }

  /// Check Out visitor
  Future<bool> checkOutVisitor(String id) async {
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index == -1) return false;

    final updated = _visitors[index].copyWith(
      status: VisitorStatus.checkedOut,
      checkOutTime: DateTime.now().toIso8601String(),
    );

    _visitors[index] = updated;
    await _storageService.saveVisitors(_visitors);
    _lastSyncTime = DateTime.now();
    notifyListeners();

    try {
      await _apiServices.patchVisitorStatus(id, VisitorStatus.checkedOut);
    } catch (_) {
      // Retained in local cache
    }
    return true;
  }

  /// Register new visitor
  Future<bool> registerVisitor(Visitor visitor) async {
    final newId = visitor.id.isNotEmpty
        ? visitor.id
        : (_visitors.length + 1).toString();
    final passNumber = visitor.passNumber ??
        'SUM-2024-${newId.padLeft(3, '0')}';

    final toAdd = visitor.copyWith(
      id: newId,
      passNumber: passNumber,
      createdAt: DateTime.now().toIso8601String(),
    );

    _visitors.insert(0, toAdd);
    await _storageService.saveVisitors(_visitors);
    _lastSyncTime = DateTime.now();
    notifyListeners();

    try {
      await _apiServices.createVisitor(toAdd);
    } catch (_) {
      // Retained in local cache
    }
    return true;
  }

  /// Update existing visitor
  Future<bool> updateVisitor(Visitor visitor) async {
    final index = _visitors.indexWhere((v) => v.id == visitor.id);
    if (index == -1) return false;

    _visitors[index] = visitor;
    await _storageService.saveVisitors(_visitors);
    _lastSyncTime = DateTime.now();
    notifyListeners();

    try {
      await _apiServices.updateVisitor(visitor);
    } catch (_) {
      // Retained in local cache
    }
    return true;
  }

  /// Delete visitor
  Future<bool> deleteVisitor(String id) async {
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index == -1) return false;

    _visitors.removeAt(index);
    await _storageService.saveVisitors(_visitors);
    _lastSyncTime = DateTime.now();
    notifyListeners();

    try {
      await _apiServices.deleteVisitor(id);
    } catch (_) {
      // Retained in local cache
    }
    return true;
  }
}
