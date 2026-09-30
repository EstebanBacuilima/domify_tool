import 'package:domify_tool/core/error/failure_messages.dart';
import 'package:domify_tool/features/auth/presentation/cubit/login_cubit.dart';
import 'package:domify_tool/features/auth/presentation/cubit/login_state.dart';
import 'package:domify_tool/features/auth/presentation/cubit/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordHidden = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // Closes the keyboard so the error, if any, is not hidden behind it.
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<LoginCubit, LoginState>(
          // The cubit does not know the session exists; the screen hands the
          // user over. That is what keeps one cubit from depending on another.
          listenWhen: (previous, current) => current is LoginSuccess,
          listener: (context, state) => context.read<SessionCubit>().onSignedIn(
            (state as LoginSuccess).user,
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'DomifyTool',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 32),
                      _EmailField(controller: _emailController),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _passwordController,
                        hidden: _passwordHidden,
                        onToggle: () =>
                            setState(() => _passwordHidden = !_passwordHidden),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 24),
                      // Only this part depends on the state, so typing does not
                      // rebuild the fields.
                      _SubmitSection(onSubmit: _submit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    autocorrect: false,
    autofillHints: const [AutofillHints.username],
    decoration: const InputDecoration(labelText: 'Correo'),
    onChanged: (_) => context.read<LoginCubit>().clearError(),
    validator: (value) {
      final email = value?.trim() ?? '';
      if (email.isEmpty) return 'Escribe tu correo';
      if (!email.contains('@')) return 'Ese correo no parece válido';
      return null;
    },
  );
}


class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hidden,
    required this.onToggle,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool hidden;
  final VoidCallback onToggle;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: hidden,
    textInputAction: TextInputAction.done,
    autofillHints: const [AutofillHints.password],
    onFieldSubmitted: onSubmitted,
    onChanged: (_) => context.read<LoginCubit>().clearError(),
    decoration: InputDecoration(
      labelText: 'Contraseña',
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
        tooltip: hidden ? 'Mostrar contraseña' : 'Ocultar contraseña',
      ),
    ),
    validator: (value) =>
        (value ?? '').isEmpty ? 'Escribe tu contraseña' : null,
  );
}

class _SubmitSection extends StatelessWidget {
  const _SubmitSection({required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => switch (state) {
        LoginSubmitting() => const FilledButton(
          onPressed: null,
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        LoginError(:final failure) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ErrorText(failure.message),
            const SizedBox(height: 12),
            FilledButton(onPressed: onSubmit, child: const Text('Entrar')),
          ],
        ),
        // Initial and success paint the same button: on success the screen is
        // already on its way out, and swapping it for a spinner would flash.
        LoginInitial() || LoginSuccess() => FilledButton(
          onPressed: onSubmit,
          child: const Text('Entrar'),
        ),
      },
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
