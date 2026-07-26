import 'package:test/test.dart';
void main() {
  group('A group of tests', () {
    int value1 = 1;
    int value2 = 2;

    int sum = value1+value2;

    test('First Test', () {
      expect(sum, 3);
    });
  });
}
