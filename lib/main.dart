import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'data/repositories/local_storage_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/subscriptions/bloc/subscription_bloc.dart';
import 'features/subscriptions/ui/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repository = LocalStorageRepository(prefs);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final LocalStorageRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(repository)..add(CheckAuthRequested()),
        ),
        BlocProvider<SubscriptionBloc>(
          create: (context) => SubscriptionBloc(repository),
        ),
      ],
      child: MaterialApp(
        title: 'Subscription Reminder POC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return Scaffold(
                backgroundColor: AppTheme.background,
                body: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Image.asset(
                      'assets/app_icon.jpeg',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              );
            } else if (state is Authenticated) {
              return const DashboardScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
