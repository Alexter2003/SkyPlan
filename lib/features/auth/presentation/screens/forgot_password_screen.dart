import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/usecases/forgot_password.dart';
import '../state/forgot_password_controller.dart';
import '../widgets/auth_scaffold.dart';

/// Pantalla para pedir una contraseña temporal por correo.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key, this.email = '', this.notice});

  final String email;

  /// Aviso previo (por ejemplo, "la contraseña temporal expiró").
  final String? notice;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ForgotPasswordController(context.read<ForgotPassword>()),
      child: _ForgotPasswordView(email: email, notice: notice),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView({required this.email, required this.notice});

  final String email;
  final String? notice;

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController(
    text: widget.email,
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit(ForgotPasswordController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await controller.submit(email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ForgotPasswordController>();
    final typography = context.skyTypography;
    final colors = context.skyColors;

    return AuthScaffold(
      title: 'Recupera tu contraseña',
      subtitle: 'Te enviaremos una contraseña temporal a tu correo.',
      leading: SkyIconButton(
        icon: SkyIconType.arrowLeft,
        tooltip: 'Volver',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      children: [
        Form(
          key: _formKey,
          child: SkyShake(
            shakeKey: controller.shakeCount,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.notice != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SkySpacing.md),
                    child: SkyInlineAlert(
                      message: widget.notice!,
                      tone: SkyInlineAlertTone.warning,
                    ),
                  ),
                if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SkySpacing.md),
                    child: SkyInlineAlert(message: controller.errorMessage!),
                  ),
                if (controller.sent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SkySpacing.md),
                    child: SkyInlineAlert(
                      message:
                          'Si el correo está registrado, recibirás una '
                          'contraseña temporal.',
                      tone: SkyInlineAlertTone.info,
                    ),
                  ),
                SkyEmailField(
                  controller: _emailController,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: SkySpacing.xs),
                Text(
                  'La contraseña temporal expira en 30 minutos y solo se '
                  'envía una cada 5 minutos. Úsala para iniciar sesión y '
                  'elegir tu propia contraseña.',
                  style: typography.caption.copyWith(color: colors.subtle),
                ),
                const SizedBox(height: SkySpacing.xl),
                SkyButton(
                  label: controller.sent ? 'Enviar de nuevo' : 'Enviar',
                  expand: true,
                  loading: controller.isLoading,
                  onPressed: () => _submit(controller),
                ),
                const SizedBox(height: SkySpacing.sm),
                SkyButton(
                  label: 'Volver a iniciar sesión',
                  variant: SkyButtonVariant.ghost,
                  expand: true,
                  onPressed: controller.isLoading
                      ? null
                      : () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
