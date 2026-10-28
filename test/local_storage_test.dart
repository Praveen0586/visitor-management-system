import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vms/core/configs/storage/local_storage_service.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService Unit Tests', () {
    test('getCachedVisitors returns empty list when cache is empty', () async {
      final storage = LocalStorageService();
      final visitors = await storage.getCachedVisitors();
      expect(visitors, isEmpty);
    });

    test('saveVisitors persists visitors and getCachedVisitors retrieves them', () async {
      final storage = LocalStorageService();
      const visitor = Visitor(
        id: '1',
        name: 'Rahul Sharma',
        mobile: '9876543210',
        visitorType: VisitorCategory.customer,
        project: 'Project A',
        purpose: 'Site Visit',
        status: VisitorStatus.checkedIn,
        createdAt: '2024-10-24T09:00:00Z',
      );

      final saved = await storage.saveVisitors([visitor]);
      expect(saved, isTrue);

      final retrieved = await storage.getCachedVisitors();
      expect(retrieved.length, 1);
      expect(retrieved.first.id, '1');
      expect(retrieved.first.name, 'Rahul Sharma');
      expect(retrieved.first.status, VisitorStatus.checkedIn);
    });

    test('clearCache removes stored data', () async {
      final storage = LocalStorageService();
      const visitor = Visitor(
        id: '1',
        name: 'Rahul Sharma',
        mobile: '9876543210',
        visitorType: VisitorCategory.customer,
        project: 'Project A',
        purpose: 'Site Visit',
        createdAt: '2024-10-24T09:00:00Z',
      );

      await storage.saveVisitors([visitor]);
      expect((await storage.getCachedVisitors()).length, 1);

      await storage.clearCache();
      expect((await storage.getCachedVisitors()), isEmpty);
    });
  });
}
