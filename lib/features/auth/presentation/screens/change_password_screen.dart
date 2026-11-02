import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/change_password.dart';
import '../state/change_password_controller.dart';
import '../state/session_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_rules_checklist.dart';

/// Cambio de contraseña obligatorio tras iniciar con una temporal.
///
/// No se puede abandonar: sin botón de retroceso y con el gesto bloqueado.
/// Solo se sale cambiando la contraseña o cerrando sesión.
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ChangePasswordController(context.read<ChangePassword>()),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _newController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(ChangePasswordController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final session = context.read<SessionController>();
    final navigator = Navigator.of(context);
    final outcome = await controller.submit(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
      confirmNewPassword: _confirmController.text,
    );
    if (!mounted) return;

    switch (outcome) {
      case ChangePasswordOutcome.success:
        session.completePasswordChange();
        SkySnackbar.show(
          context,
          'Contraseña actualizada',
          tone: SkySnackbarTone.success,
        );
        navigator.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
      case ChangePasswordOutcome.temporaryExpired:
        await session.endSession();
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.forgotPassword,
          (_) => false,
          arguments: ForgotPasswordArgs(notice: controller.errorMessage),
        );
      case ChangePasswordOutcome.failed:
        break;
    }
  }

  Future<void> _logout() async {
    setState(() => _leaving = true);
    final navigator = Navigator.of(context);
    await context.read<SessionController>().endSession();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChangePasswordController>();

    return PopScope(
      canPop: false,
      child: AuthScaffold(
        title: 'Elige tu contraseña',
        subtitle:
            'Iniciaste con una contraseña temporal. Define la tuya para '
            'continuar.',
        children: [
          Form(
            key: _formKey,
            child: SkyShake(
              shakeKey: controller.shakeCount,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SkySpacing.md),
                      child: SkyInlineAlert(
                        message: controller.errorMessage!,
                        details: controller.errorDetails,
                      ),
                    ),
                  SkyPasswordField(
                    controller: _currentController,
                    label: 'Contraseña temporal',
                    textInputAction: TextInputAction.next,
                    validator: (v) => SkyValidators.required(
                      v,
                      field: 'La contraseña temporal',
                    ),
                  ),
                  const SizedBox(height: SkySpacing.sm),
                  SkyPasswordField(
                    controller: _newController,
                    label: 'Nueva contraseña',
                    textInputAction: TextInputAction.next,
                    validator: SkyValidators.password,
                  ),
                  PasswordRulesChecklist(password: _newController.text),
                  const SizedBox(height: SkySpacing.sm),
                  SkyPasswordField(
                    controller: _confirmController,
                    label: 'Confirmar nueva contraseña',
                    textInputAction: TextInputAction.done,
                    confirms: () => _newController.text,
                  ),
                  const SizedBox(height: SkySpacing.xl),
                  SkyButton(
                    label: 'Guardar contraseña',
                    expand: true,
                    loading: controller.isLoading,
                    onPressed: () => _submit(controller),
                  ),
                  const SizedBox(height: SkySpacing.sm),
                  SkyButton(
                    label: 'Cerrar sesión',
                    variant: SkyButtonVariant.ghost,
                    expand: true,
                    loading: _leaving,
                    onPressed: controller.isLoading ? null : _logout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
