import 'package:fluffychat/views/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  /// All Tests related to the Login
  group("LoginPage", () {
    /// Check if all Elements get created
    testWidgets('should get created', (WidgetTester tester) async {
      await tester.runAsync(() async {
        final TestObserver observer = TestObserver()
          ..onPushed = (Route<dynamic> route, Route<dynamic> previousRoute) {}
          ..onPopped = (Route<dynamic> route, Route<dynamic> previousRoute) {};

        await tester.pumpWidget(
          Utils.getWidgetWrapper(
            Login(),
            observer,
          ),
        );

        await tester.pump(Duration.zero);

        expect(find.byKey(Key("serverField")), findsOneWidget); // Server field
        expect(
            find.byKey(Key("usernameField")), findsOneWidget); // Username Input
        expect(
            find.byKey(Key("passwordField")), findsOneWidget); // Password Input
        expect(find.byKey(Key("loginButton")), findsOneWidget); // Login Button
      });
    });
  });
}
