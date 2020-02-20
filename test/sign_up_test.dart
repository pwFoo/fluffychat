import 'package:fluffychat/views/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  /// All Tests related to the Login
  group("SignUpPage", () {
    /// Check if all Elements get created
    testWidgets('should get created', (WidgetTester tester) async {
      await tester.runAsync(() async {
        final TestObserver observer = TestObserver()
          ..onPushed = (Route<dynamic> route, Route<dynamic> previousRoute) {}
          ..onPopped = (Route<dynamic> route, Route<dynamic> previousRoute) {};

        await tester.pumpWidget(
          Utils.getWidgetWrapper(
            SignUp(),
            observer,
          ),
        );

        await tester.pump(Duration.zero);

        expect(find.byKey(Key("serverField")), findsOneWidget); // Server field
        expect(
            find.byKey(Key("usernameField")), findsOneWidget); // Username Input
        expect(find.byKey(Key("signUpButton")), findsOneWidget); // Login Button
        expect(find.byKey(Key("alreadyHaveAnAccountButton")),
            findsOneWidget); // alreadyHaveAnAccount Button

        /*await Utils.tapItem(tester, Key("loginButton"));
        // FIXME Use better way
        await tester.pump(Duration(seconds: 5));
        expect(isPushed, isTrue);*/
      });
    });
  });
}
