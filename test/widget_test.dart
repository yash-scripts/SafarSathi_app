import 'package:flutter_test/flutter_test.dart';
import 'package:yatrica/main.dart';
import 'package:yatrica/screens/login_screen.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const YatricaApp());

    // Verify that our app starts with the LoginScreen.
    expect(find.byType(LoginScreen), findsOneWidget);

    // Verify that the title is present.
    expect(find.text('Yatrica'), findsAtLeastNWidgets(1));

    // Verify that the "Welcome" text is present.
    expect(find.text('Welcome to Yatrica'), findsOneWidget);

    // Verify that the "Continue as Guest" button is present.
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}
