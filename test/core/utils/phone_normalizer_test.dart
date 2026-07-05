import 'package:flutter_test/flutter_test.dart';
import 'package:nexa_stays_f/core/utils/phone_normalizer.dart';

void main() {
  test('strips national 0 after +212', () {
    expect(normalizeMoroccoPhone('+2120612345678'), '+212612345678');
    expect(normalizeMoroccoPhone('0612345678'), '+212612345678');
  });
}
