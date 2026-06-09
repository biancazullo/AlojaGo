import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyec/main.dart';

import 'fakes/fake_auth_repository.dart';

void main() {
  testWidgets('home renders the Aloja entry point', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(AlojaApp(authRepository: FakeAuthRepository()));

    await tester.pump();

    expect(find.text('Destinos Destacados'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
