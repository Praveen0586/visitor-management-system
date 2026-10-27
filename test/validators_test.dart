import 'package:flutter_test/flutter_test.dart';
import 'package:vms/core/utils/validators.dart';

void main() {
  group('AppValidators Tests', () {
    test('validateName accepts valid names', () {
      expect(AppValidators.validateName('Rahul Sharma'), isNull);
      expect(AppValidators.validateName('Meena Iyer'), isNull);
      expect(AppValidators.validateName('A. Kumar'), isNull);
    });

    test('validateName rejects empty or too short names', () {
      expect(AppValidators.validateName(''), 'Name is required for guest badge creation');
      expect(AppValidators.validateName('   '), 'Name is required for guest badge creation');
      expect(AppValidators.validateName('A'), 'Name must be at least 2 characters');
    });

    test('validateMobile validates 10 digit Indian mobile numbers', () {
      expect(AppValidators.validateMobile('9876543210'), isNull);
      expect(AppValidators.validateMobile('8888888888'), isNull);
      expect(AppValidators.validateMobile('7000000000'), isNull);
      expect(AppValidators.validateMobile('6123456789'), isNull);

      // Remaining count indicator
      expect(AppValidators.validateMobile('98765'), 'Enter a valid 10-digit mobile number (5 remaining)');
      // Invalid starting digit
      expect(AppValidators.validateMobile('1234567890'), 'Must be a valid 10-digit mobile starting with 6, 7, 8, or 9');
    });

    test('validateEmail validates optional emails correctly', () {
      expect(AppValidators.validateEmail(null), isNull);
      expect(AppValidators.validateEmail(''), isNull);
      expect(AppValidators.validateEmail('visitor@company.com'), isNull);
      expect(AppValidators.validateEmail('invalid-email'), 'Please enter a valid email address');
    });

    test('validatePurpose validates required non-empty string under 120 chars', () {
      expect(AppValidators.validatePurpose('Site Visit'), isNull);
      expect(AppValidators.validatePurpose(''), 'Purpose of visit is required');
      expect(AppValidators.validatePurpose('a' * 121), 'Purpose cannot exceed 120 characters');
    });
  });
}
