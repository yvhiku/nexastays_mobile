import 'package:flutter_test/flutter_test.dart';
import 'package:nexa_stays_f/core/utils/phone_normalizer.dart';

void main() {
  test('strips national 0 after +212', () {
    expect(normalizeMoroccoPhone('+2120612345678'), '+212612345678');
    expect(normalizeMoroccoPhone('0612345678'), '+212612345678');
  });

  test('preserves international dial codes', () {
    expect(normalizePhone('+33612345678'), '+33612345678');
    expect(normalizePhone('+12025551234'), '+12025551234');
    expect(normalizePhone('0033612345678'), '+33612345678');
  });

  test('isValidE164 accepts non-MA numbers', () {
    expect(isValidE164('+33612345678'), isTrue);
    expect(isValidE164('+212612345678'), isTrue);
    expect(isValidE164('+212612'), isFalse);
  });
}
