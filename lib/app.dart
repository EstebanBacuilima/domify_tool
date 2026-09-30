import 'package:dio/dio.dart';
import 'package:domify_tool/core/network/api_client.dart';
import 'package:domify_tool/core/network/auth_interceptor.dart';
import 'package:domify_tool/core/session/secure_token_store.dart';
import 'package:domify_tool/core/theme/app_theme.dart';
import 'package:domify_tool/features/auth/data/repositories/http_auth_repository.dart';
import 'package:domify_tool/features/auth/data/sources/auth_remote_source.dart';
import 'package:domify_tool/features/auth/domain/repositories/auth_repository.dart';
import 'package:domify_tool/features/auth/presentation/cubit/session_cubit.dart';
import 'package:domify_tool/features/auth/presentation/cubit/session_state.dart';
import 'package:domify_tool/features/auth/presentation/view/login_page.dart';
import 'package:domify_tool/features/home/presentation/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Composition root: the only place that names concrete implementations.
class DomifyApp extends StatelessWidget {
  const DomifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      // The type argument is written out on purpose: registered as the
      // concrete class, every `context.read` would have to change the day the
      // implementation does.
      create: (_) => _buildAuthRepository(),
      child: BlocProvider(
        create: (context) =>
            SessionCubit(context.read<AuthRepository>())..start(),
        child: MaterialApp(
          title: 'DomifyTool',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const SessionGate(),
        ),
      ),
    );
  }
}

/// Which screen the session state calls for. This is the whole navigation the
/// app needs today, which is why there is no router yet.
///
/// Public so a test can mount it over a fake repository, which is the closest
/// thing to running the app without a device.
class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) => switch (state) {
        SessionChecking() => const _Splash(),
        SessionActive(:final user) => HomePage(user: user),
        SessionClosed() => const LoginPage(),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

/// Wires the auth stack.
///
/// Order matters: the Dio instance has to exist before the interceptor, and
/// the interceptor renews through the same client, which is why it is added
/// afterwards instead of being passed in.
AuthRepository _buildAuthRepository() {
  const tokenStore = SecureTokenStore(FlutterSecureStorage());
  final Dio dio = createDio();
  final source = AuthRemoteSource(ApiClient(dio));

  dio.interceptors.add(
    AuthInterceptor(dio, tokenStore, (refreshToken) async {
      final tokens = await source.refresh(refreshToken);
      return (accessToken: tokens.token, refreshToken: tokens.refreshToken);
    }),
  );

  return HttpAuthRepository(source, tokenStore);
}
