import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/register_user.dart';
import '../state/register_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_rules_checklist.dart';

/// Pantalla de registro.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterController(context.read<RegisterUser>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit(RegisterController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    await controller.submit(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmationController.text,
    );

    final email = controller.registeredEmail;
    if (email != null && mounted) {
      SkySnackbar.show(
        context,
        'Cuenta creada. Revisa tu correo para confirmar.',
        tone: SkySnackbarTone.success,
      );
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.confirmEmail,
        arguments: ConfirmEmailArgs(email: email),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RegisterController>();

    return AuthScaffold(
      title: 'Crea tu cuenta',
      subtitle: 'Planifica tus actividades según el clima, en un solo lugar.',
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
                            details: controller.errorDetails,
                          ),
                        ),
                ),
                SkyEmailField(controller: _emailController),
                const SizedBox(height: SkySpacing.sm),
                SkyTextField(
                  controller: _usernameController,
                  label: 'Nombre de usuario',
                  leadingIcon: SkyIconType.user,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newUsername],
                  validator: SkyValidators.username,
                ),
                const SizedBox(height: SkySpacing.sm),
                SkyPasswordField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  textInputAction: TextInputAction.next,
                  validator: SkyValidators.password,
                ),
                PasswordRulesChecklist(password: _passwordController.text),
                const SizedBox(height: SkySpacing.sm),
                SkyPasswordField(
                  controller: _confirmationController,
                  label: 'Confirmar contraseña',
                  textInputAction: TextInputAction.done,
                  confirms: () => _passwordController.text,
                ),
                const SizedBox(height: SkySpacing.xl),
                SkyButton(
                  label: 'Crear cuenta',
                  expand: true,
                  loading: controller.isLoading,
                  onPressed: () => _submit(controller),
                ),
                const SizedBox(height: SkySpacing.sm),
                SkyButton(
                  label: 'Ya tengo cuenta',
                  variant: SkyButtonVariant.ghost,
                  expand: true,
                  onPressed: controller.isLoading
                      ? null
                      : () => Navigator.of(
                          context,
                        ).pushReplacementNamed(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
