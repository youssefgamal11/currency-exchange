import 'package:axis/core%20/utils/common_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonFunctions.formatDate', () {
    test('zero-pads month and day', () {
      expect(CommonFunctions.formatDate(DateTime(2026, 7, 5)), '2026-07-05');
    });

    test('leaves two-digit month and day intact', () {
      expect(CommonFunctions.formatDate(DateTime(2026, 12, 25)), '2026-12-25');
    });
  });

  group('CommonFunctions.formatTime', () {
    test('midnight is 12:00 AM', () {
      expect(CommonFunctions.formatTime(DateTime(2026, 1, 1, 0, 0)), '12:00 AM');
    });

    test('noon is 12:00 PM', () {
      expect(CommonFunctions.formatTime(DateTime(2026, 1, 1, 12, 0)), '12:00 PM');
    });

    test('afternoon converts to 12-hour and pads minutes', () {
      expect(CommonFunctions.formatTime(DateTime(2026, 1, 1, 15, 5)), '3:05 PM');
    });
  });

  group('CommonFunctions.formatShortDate', () {
    test('renders "Mon D"', () {
      expect(CommonFunctions.formatShortDate(DateTime(2026, 7, 5)), 'Jul 5');
      expect(CommonFunctions.formatShortDate(DateTime(2026, 1, 31)), 'Jan 31');
      expect(CommonFunctions.formatShortDate(DateTime(2026, 12, 1)), 'Dec 1');
    });
  });
}
