import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vms/core/configs/api/api_services.dart';
import 'package:vms/core/configs/storage/local_storage_service.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';
import 'package:vms/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:vms/main.dart';

final List<Visitor> _testVisitors = [
  const Visitor(
    id: '1',
    name: 'Rahul Sharma',
    mobile: '9876543210',
    visitorType: VisitorCategory.customer,
    project: 'Project A',
    purpose: 'Site Visit',
    status: VisitorStatus.checkedIn,
    createdAt: '2024-10-24T09:00:00Z',
  ),
  const Visitor(
    id: '2',
    name: 'Priya Nair',
    mobile: '9845012345',
    visitorType: VisitorCategory.customer,
    project: 'Project B',
    purpose: 'Flat Booking Discussion',
    status: VisitorStatus.checkedOut,
    createdAt: '2024-10-24T09:10:00Z',
  ),
  const Visitor(
    id: '3',
    name: 'Suresh Kumar',
    mobile: '9790123456',
    visitorType: VisitorCategory.vendor,
    project: 'Project A',
    purpose: 'Material Delivery',
    status: VisitorStatus.checkedOut,
    createdAt: '2024-10-24T09:20:00Z',
  ),
  const Visitor(
    id: '4',
    name: 'Anjali Reddy',
    mobile: '9701234567',
    visitorType: VisitorCategory.customer,
    project: 'Project C',
    purpose: 'Home Loan Documentation',
    status: VisitorStatus.checkedIn,
    createdAt: '2024-10-24T09:30:00Z',
  ),
  const Visitor(
    id: '5',
    name: 'Karthik Raj',
    mobile: '9600987654',
    visitorType: VisitorCategory.vendor,
    project: 'Project B',
    purpose: 'Electrical Maintenance',
    status: VisitorStatus.checkedIn,
    createdAt: '2024-10-24T09:40:00Z',
  ),
  const Visitor(
    id: '6',
    name: 'Meena Iyer',
    mobile: '9885432109',
    visitorType: VisitorCategory.customer,
    project: 'Project A (Sumadhura Horizon)',
    purpose: 'Site Visit',
    status: VisitorStatus.registered,
    createdAt: '2024-10-24T09:15:00Z',
  ),
  const Visitor(
    id: '7',
    name: 'Vikram Singh',
    mobile: '9912345678',
    visitorType: VisitorCategory.other,
    project: 'Project C',
    purpose: 'Government Inspection',
    status: VisitorStatus.registered,
    createdAt: '2024-10-24T10:15:00Z',
  ),
  const Visitor(
    id: '8',
    name: 'Deepa Mohan',
    mobile: '9741122334',
    visitorType: VisitorCategory.customer,
    project: 'Project B',
    purpose: 'Agreement Signing',
    status: VisitorStatus.registered,
    createdAt: '2024-10-24T10:30:00Z',
  ),
];

class MockApiServices extends ApiServices {
  @override
  Future<List<Visitor>> getAllVisitors() async {
    return List.from(_testVisitors);
  }

  @override
  Future<Visitor> patchVisitorStatus(String id, String newStatus, {DateTime? timestamp}) async {
    final now = timestamp ?? DateTime.now();
    return Visitor(
      id: id,
      name: 'Mock',
      mobile: '9876543210',
      visitorType: VisitorCategory.customer,
      project: 'Project A',
      purpose: 'Site Visit',
      status: newStatus,
      createdAt: now.toIso8601String(),
    );
  }
}

class MockLocalStorageService extends LocalStorageService {
  List<Visitor> _store = [];

  MockLocalStorageService({List<Visitor>? initial}) {
    _store = initial ?? List.from(_testVisitors);
  }

  @override
  Future<List<Visitor>> getCachedVisitors() async {
    return List.from(_store);
  }

  @override
  Future<bool> saveVisitors(List<Visitor> visitors) async {
    _store = List.from(visitors);
    return true;
  }

  @override
  Future<bool> clearCache() async {
    _store.clear();
    return true;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Visitor Model Tests', () {
    test('Visitor serializes and deserializes correctly', () {
      final json = {
        'id': '10',
        'name': 'Test Visitor',
        'mobile': '9876543210',
        'email': 'test@example.com',
        'visitor_type': 'Customer',
        'project': 'Project A',
        'purpose': 'Site Visit',
        'status': 'Registered',
        'created_at': '2024-10-24T10:00:00Z',
      };

      final visitor = Visitor.fromJson(json);
      expect(visitor.id, '10');
      expect(visitor.name, 'Test Visitor');
      expect(visitor.initials, 'TV');
      expect(visitor.isRegistered, isTrue);
      expect(visitor.canCheckIn, isTrue);
      expect(visitor.canCheckOut, isFalse);

      final exported = visitor.toJson();
      expect(exported['name'], 'Test Visitor');
      expect(exported['visitor_type'], 'Customer');
    });

    test('Visitor copyWith and patch works', () {
      const visitor = Visitor(
        id: '1',
        name: 'Rahul',
        mobile: '9876543210',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Site Visit',
        createdAt: '2024-10-24T10:00:00Z',
      );

      final checkedIn = visitor.copyWith(status: VisitorStatus.checkedIn);
      expect(checkedIn.isCheckedIn, isTrue);
      expect(checkedIn.canCheckOut, isTrue);
    });
  });

  group('DashboardViewModel Tests with Local Storage', () {
    test('Calculates metrics and filters accurately from cache', () async {
      final mockStorage = MockLocalStorageService(initial: _testVisitors);
      final vm = DashboardViewModel(
        apiServices: MockApiServices(),
        storageService: mockStorage,
        autoFetch: false,
      );

      await vm.init();

      expect(vm.totalVisitorsCount, 8);
      expect(vm.currentlyCheckedInCount, 3);
      expect(vm.checkedOutCount, 2);
      expect(vm.registeredCount, 3);

      // Filter by Checked In
      vm.setFilter(VisitorStatus.checkedIn);
      expect(vm.filteredVisitors.length, 3);
      expect(vm.filteredVisitors.every((v) => v.isCheckedIn), isTrue);

      // Search by Name
      vm.setFilter('All');
      vm.setSearchQuery('Rahul');
      expect(vm.filteredVisitors.length, 1);
      expect(vm.filteredVisitors.first.name, 'Rahul Sharma');

      // Clear search
      vm.clearFiltersAndSearch();
      expect(vm.filteredVisitors.length, 8);
    });

    test('Check-in updates state and persists to local storage', () async {
      final mockStorage = MockLocalStorageService(initial: _testVisitors);
      final vm = DashboardViewModel(
        apiServices: MockApiServices(),
        storageService: mockStorage,
        autoFetch: false,
      );

      await vm.init();

      // Meena Iyer is ID 6 and Registered
      final meena = vm.allVisitors.firstWhere((v) => v.id == '6');
      expect(meena.isRegistered, isTrue);

      await vm.checkInVisitor('6');
      final meenaCheckedIn = vm.allVisitors.firstWhere((v) => v.id == '6');
      expect(meenaCheckedIn.isCheckedIn, isTrue);

      // Verify it was persisted to storage
      final cached = await mockStorage.getCachedVisitors();
      expect(cached.firstWhere((v) => v.id == '6').isCheckedIn, isTrue);

      await vm.checkOutVisitor('6');
      final meenaCheckedOut = vm.allVisitors.firstWhere((v) => v.id == '6');
      expect(meenaCheckedOut.isCheckedOut, isTrue);
    });

    test('Visitors are sorted by latest activity (registration, check-in, check-out)', () async {
      final mockStorage = MockLocalStorageService(initial: _testVisitors);
      final vm = DashboardViewModel(
        apiServices: MockApiServices(),
        storageService: mockStorage,
        autoFetch: false,
      );

      await vm.init();

      // Check in visitor 3 (Suresh Kumar)
      await vm.checkInVisitor('3');
      // Suresh Kumar should now be at the very top because check-in is the newest activity
      expect(vm.filteredVisitors.first.id, '3');

      // Now check out visitor 1 (Rahul Sharma)
      await vm.checkOutVisitor('1');
      // Rahul Sharma should now be at the top because check-out is the newest activity
      expect(vm.filteredVisitors.first.id, '1');
    });
  });

  group('Widget Smoke Test', () {
    testWidgets('App renders dashboard with headers and tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const VmsApp());
      await tester.pumpAndSettle();

      // Verify Dashboard AppHeader
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Visitor Management'), findsOneWidget);
      expect(find.text('Total Visitors Today'), findsOneWidget);

      // Verify Action buttons
      expect(find.text('REGISTER VISITOR'), findsOneWidget);
      expect(find.text('SCAN QR CODE'), findsOneWidget);

      // Verify bottom navigation items
      expect(find.text('Visitors'), findsWidgets);
      expect(find.text('Scan'), findsOneWidget);
    });
  });
}
