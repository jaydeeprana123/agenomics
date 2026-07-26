import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

import 'package:agenomics/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await GetStorage.init();
  });

  testWidgets('Login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AGenomicsApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
