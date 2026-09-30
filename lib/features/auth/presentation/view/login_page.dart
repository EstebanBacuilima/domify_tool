import 'package:domify_tool/features/auth/domain/repositories/auth_repository.dart';
import 'package:domify_tool/features/auth/presentation/cubit/login_cubit.dart';
import 'package:domify_tool/features/auth/presentation/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Provides the cubit; it paints nothing.
///
/// Split from the view because `context.read` searches upwards and a widget
/// never sees what it provides itself: reading the cubit here would throw
/// `ProviderNotFoundException`.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => LoginCubit(context.read<AuthRepository>()),
    child: const LoginView(),
  );
}
