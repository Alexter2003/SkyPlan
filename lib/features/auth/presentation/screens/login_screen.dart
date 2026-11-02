import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/login.dart';
import '../state/login_controller.dart';
import '../state/session_controller.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla de login.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginController(context.read<Login>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(LoginController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final session = await controller.submit(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );
    if (session == null || !mounted) return;

    await context.read<SessionController>().establish(session);
    if (!mounted) return;

    final navigator = Navigator.of(context);
    if (session.mustChangePassword) {
      navigator.pushNamedAndRemoveUntil(AppRoutes.changePassword, (_) => false);
      return;
    }
    navigator.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  void _goToForgotPassword() {
    final identifier = _identifierController.text.trim();
    Navigator.of(context).pushNamed(
      AppRoutes.forgotPassword,
      arguments: ForgotPasswordArgs(
        email: identifier.contains('@') ? identifier : '',
      ),
    );
  }

  void _goToConfirmEmail() {
    final identifier = _identifierController.text.trim();
    final email = identifier.contains('@') ? identifier : '';
    Navigator.of(context).pushNamed(
      AppRoutes.confirmEmail,
      arguments: ConfirmEmailArgs(email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoginController>();

    return AuthScaffold(
      title: 'Bienvenido de vuelta',
      subtitle: 'Inicia sesión para ver tu planificador.',
      children: [
        Form(
          key: _formKey,
          child: SkyShake(
            shakeKey: controller.shakeCount,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: SkyMotion.base,
                  child: controller.errorMessage == null
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey(controller.errorMessage),
                          padding: const EdgeInsets.only(bottom: SkySpacing.md),
                          child: SkyInlineAlert(
                            message: controller.errorMessage!,
                            tone:
                                controller.failureKind ==
                                    LoginFailureKind.unconfirmedEmail
                                ? SkyInlineAlertTone.warning
                                : SkyInlineAlertTone.error,
                            actionLabel:
                                controller.failureKind ==
                                    LoginFailureKind.unconfirmedEmail
                                ? 'Confirmar ahora'
                                : null,
                            onAction:
                                controller.failureKind ==
                                    LoginFailureKind.unconfirmedEmail
                                ? _goToConfirmEmail
                                : null,
                          ),
                        ),
                ),
                SkyTextField(
                  controller: _identifierController,
                  label: 'Correo o nombre de usuario',
                  leadingIcon: SkyIconType.mail,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  validator: SkyValidators.loginIdentifier,
                ),
                const SizedBox(height: SkySpacing.sm),
                SkyPasswordField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      SkyValidators.required(v, field: 'La contraseña'),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SkyButton(
                    label: 'Olvidé mi contraseña',
                    variant: SkyButtonVariant.ghost,
                    onPressed: controller.isLoading
                        ? null
                        : _goToForgotPassword,
                  ),
                ),
                const SizedBox(height: SkySpacing.md),
                SkyButton(
                  label: 'Iniciar sesión',
                  expand: true,
                  loading: controller.isLoading,
                  onPressed: () => _submit(controller),
                ),
                const SizedBox(height: SkySpacing.sm),
                SkyButton(
                  label: 'Crear cuenta',
                  variant: SkyButtonVariant.ghost,
                  expand: true,
                  onPressed: controller.isLoading
                      ? null
                      : () => Navigator.of(
                          context,
                        ).pushReplacementNamed(AppRoutes.register),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
