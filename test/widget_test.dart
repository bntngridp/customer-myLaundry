import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:customer_mylaundry/main.dart';
import 'package:customer_mylaundry/data/services/auth_service.dart';
import 'package:customer_mylaundry/data/repositories/auth_repository.dart';
import 'package:customer_mylaundry/ui/features/auth/view_models/auth_view_model.dart';

void main() {
  testWidgets('Customer App Initial UI Test', (WidgetTester tester) async {
    final authService = AuthService();
    final authRepository = AuthRepository(authService: authService);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: authService),
          Provider<AuthRepository>.value(value: authRepository),
          ChangeNotifierProvider<AuthViewModel>(
            create: (_) => AuthViewModel(authRepository: authRepository),
          ),
        ],
        child: const CustomerApp(),
      ),
    );

    // Verify that the onboarding screen elements are displayed since user is not logged in
    expect(find.text('Nikmati Kemudahan\ndari Rumah'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
  });
}
