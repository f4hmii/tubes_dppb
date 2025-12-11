import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movr/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Menggunakan MovrApp sesuai dengan definisi di main.dart
    await tester.pumpWidget(const MovrApp());

    // Verifikasi bahwa aplikasi berhasil dimuat dengan mengecek salah satu teks di HomePage
    expect(find.text('Featured Products'), findsOneWidget);
  });
}
