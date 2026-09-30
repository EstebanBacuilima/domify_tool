import 'package:domify_tool/features/auth/domain/entities/user_profile.dart';
import 'package:domify_tool/features/auth/presentation/cubit/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Placeholder for what the workshop will actually do. It exists so signing in
/// and signing out can be seen end to end.
class HomePage extends StatelessWidget {
  const HomePage({required this.user, super.key});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DomifyTool'),
        actions: [
          IconButton(
            onPressed: () => context.read<SessionCubit>().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(
                user.initial,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
