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
    bool autoFetch = false,
  }) : _apiServices = apiServices ?? ApiServices(),
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
  String _selectedFilter =
      'All'; // 'All', 'Checked In', 'Registered', 'Checked Out'
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

  /// Filtered visitors by status and search query, sorted by recent activity
  List<Visitor> get filteredVisitors {
    final list = _visitors.where((visitor) {
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

    list.sort((a, b) {
      final cmp = b.lastActivityTime.compareTo(a.lastActivityTime);
      if (cmp != 0) return cmp;
      final idA = int.tryParse(a.id) ?? 0;
      final idB = int.tryParse(b.id) ?? 0;
      return idB.compareTo(idA);
    });
    return list;
  }

  /// Top 4 recent visitors for Dashboard preview
  List<Visitor> get recentVisitors {
    final list = List<Visitor>.from(_visitors);
    list.sort((a, b) {
      final cmp = b.lastActivityTime.compareTo(a.lastActivityTime);
      if (cmp != 0) return cmp;
      final idA = int.tryParse(a.id) ?? 0;
      final idB = int.tryParse(b.id) ?? 0;
      return idB.compareTo(idA);
    });
    return list.take(4).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ──────────────────────── KPIS ────────────────────────
  /// Overall all-time visitors in registry
  int get totalVisitorsCount => _visitors.length;

  /// Visitors with activity today (registered, checked in, checked out, or currently checked in)
  int get todayVisitorsCount {
    final now = DateTime.now();
    return _visitors.where((v) {
      if (v.isCheckedIn) return true;
      if (v.createdDate != null && _isSameDay(v.createdDate!, now)) return true;
      if (v.checkInDate != null && _isSameDay(v.checkInDate!, now)) return true;
      if (v.checkOutDate != null && _isSameDay(v.checkOutDate!, now)) {
        return true;
      }
      return false;
    }).length;
  }

  /// Visitors currently checked in on premises
  int get currentlyCheckedInCount =>
      _visitors.where((v) => v.isCheckedIn).length;

  /// Overall all-time checked out visitors
  int get checkedOutCount => _visitors.where((v) => v.isCheckedOut).length;

  /// Visitors who checked out today
  int get checkedOutTodayCount {
    final now = DateTime.now();
    return _visitors.where((v) {
      if (!v.isCheckedOut) return false;
      if (v.checkOutDate != null) {
        return _isSameDay(v.checkOutDate!, now);
      }
      if (v.createdDate != null) {
        return _isSameDay(v.createdDate!, now);
      }
      return false;
    }).length;
  }

  /// Overall all-time registered visitors
  int get registeredCount => _visitors.where((v) => v.isRegistered).length;

  /// Visitors registered today
  int get registeredTodayCount {
    final now = DateTime.now();
    return _visitors.where((v) {
      if (!v.isRegistered) return false;
      if (v.createdDate != null) {
        return _isSameDay(v.createdDate!, now);
      }
      return false;
    }).length;
  }

  // ──────────────────────── ACTIONS ────────────────────────

  void setNavIndex(int index) {
    if (_currentNavIndex != index) {
      _currentNavIndex = index;
      _searchQuery = '';
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

  /// Sort visitors descending by their latest activity/interaction time
  void _sortVisitors() {
    _visitors.sort((a, b) {
      final cmp = b.lastActivityTime.compareTo(a.lastActivityTime);
      if (cmp != 0) return cmp;
      final idA = int.tryParse(a.id) ?? 0;
      final idB = int.tryParse(b.id) ?? 0;
      return idB.compareTo(idA);
    });
  }

  Future<void> init() async {
    try {
      final cached = await _storageService.getCachedVisitors();

      if (cached.isNotEmpty) {
        _visitors = cached;
        _sortVisitors();
        _status = ViewStatus.success;
        notifyListeners();

        fetchVisitors(silent: true);
      } else {
        _status = ViewStatus.loading;
        notifyListeners();
        await fetchVisitors(silent: false);
      }
    } catch (e) {
      _status = ViewStatus.error;
      _errorMessage = 'Failed to load initial data: $e';
      notifyListeners();
    }
  }

  Future<void> fetchVisitors({bool silent = false}) async {
    if (!silent && _visitors.isEmpty) {
      _status = ViewStatus.loading;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final remoteVisitors = await _apiServices.getAllVisitors();
      if (remoteVisitors.isNotEmpty) {
        final pendingDeletes = await _storageService.getPendingDeletedIds();

        final cleanRemote = remoteVisitors
            .where((v) => !pendingDeletes.contains(v.id))
            .toList();

        final merged = <Visitor>[];
        for (final remote in cleanRemote) {
          final local = _visitors.firstWhere(
            (v) => v.id == remote.id,
            orElse: () => remote,
          );
          merged.add(local.isPendingSync ? local : remote);
        }

        for (final local in _visitors) {
          if (local.isPendingSync && !merged.any((m) => m.id == local.id)) {
            merged.add(local);
          }
        }

        _visitors = merged;
        _sortVisitors();
        await _storageService.saveVisitors(_visitors);
      }
      _status = ViewStatus.success;
      _lastSyncTime = DateTime.now();
    } catch (e) {
      if (_visitors.isEmpty) {
        _status = ViewStatus.error;
        _errorMessage = 'Could not load visitors: $e';
      }
    } finally {
      notifyListeners();
    }
  }

  Future<bool> checkInVisitor(String id) async {
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index == -1) return false;

    // Marking pending sync and save locally
    final updated = _visitors[index].copyWith(
      status: VisitorStatus.checkedIn,
      checkInTime: DateTime.now().toIso8601String(),
      isPendingSync: true,
    );
    _visitors[index] = updated;
    _sortVisitors();
    await _storageService.saveVisitors(_visitors);
    notifyListeners();

    //Try remote sync
    try {
      await _apiServices.patchVisitorStatus(id, VisitorStatus.checkedIn);

      final index = _visitors.indexWhere((v) => v.id == id);
      _visitors[index] = _visitors[index].copyWith(isPendingSync: false);
      await _storageService.saveVisitors(_visitors);
      notifyListeners();
    } catch (_) {
      // Offline: remains isPendingSync: true in storage
    }
    return true;
  }

  Future<bool> checkOutVisitor(String id) async {
    final index = _visitors.indexWhere((v) => v.id == id);

    if (index == -1) return false;

    final updated = _visitors[index].copyWith(
      checkOutTime: DateTime.now().toIso8601String(),
      status: VisitorStatus.checkedOut,
      isPendingSync: true,
    );
    _visitors[index] = updated;
    _sortVisitors();
    await _storageService.saveVisitors(_visitors);
    notifyListeners();
    try {
      await _apiServices.patchVisitorStatus(id, VisitorStatus.checkedOut);

      final currentIndex = _visitors.indexWhere((v) => v.id == id);
      _visitors[currentIndex] = _visitors[currentIndex].copyWith(isPendingSync: false);
      await _storageService.saveVisitors(_visitors);
      notifyListeners();
    } catch (_) {}
    return true;
  }

  // /// Check Out visitor
  // Future<bool> checkOutVisitor(String id) async {
  //   final index = _visitors.indexWhere((v) => v.id == id);
  //   if (index == -1) return false;

  //   final updated = _visitors[index].copyWith(
  //     status: VisitorStatus.checkedOut,
  //     checkOutTime: DateTime.now().toIso8601String(),
  //   );

  //   _visitors[index] = updated;
  //   _sortVisitors();
  //   await _storageService.saveVisitors(_visitors);
  //   _lastSyncTime = DateTime.now();
  //   notifyListeners();

  //   try {
  //     await _apiServices.patchVisitorStatus(id, VisitorStatus.checkedOut);
  //   } catch (_) {
  //     // Retained in local cache
  //   }
  //   return true;
  // }

  /// Register new visitor
  Future<bool> registerVisitor(Visitor visitor) async {
    final newId = visitor.id.isNotEmpty
        ? visitor.id
        : (_visitors.length + 1).toString();
    final year = DateTime.now().year;
    final passNumber =
        visitor.passNumber ?? 'SUM-$year-${newId.padLeft(3, '0')}';

    final toAdd = visitor.copyWith(
      id: newId,
      passNumber: passNumber,
      createdAt: DateTime.now().toIso8601String(),
    );

    _visitors.insert(0, toAdd);
    _sortVisitors();
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
    _sortVisitors();
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

    // 1. Remove locally immediately (instant UI response)
    _visitors.removeAt(index);
    await _storageService.saveVisitors(_visitors);
    notifyListeners();

    // 2. Mark this ID as pending deletion so it can't be resurrected
    await _storageService.addPendingDeletedId(id);

    // 3. Try deleting on server
    try {
      await _apiServices.deleteVisitor(id);
      // Success: clean up pending delete ID
      await _storageService.removePendingDeletedId(id);
    } catch (_) {
      // Offline: stays in pending deletes queue
    }
    return true;
  }
}
