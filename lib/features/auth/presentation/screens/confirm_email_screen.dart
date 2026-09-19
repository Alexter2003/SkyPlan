import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/routing/app_routes.dart';
import '../../domain/usecases/confirm_email.dart';
import '../../domain/usecases/resend_confirmation.dart';
import '../state/confirm_email_controller.dart';
import '../widgets/resend_code_button.dart';

const _resendCooldownSeconds = 60;

/// Pantalla de confirmación de correo.
class ConfirmEmailScreen extends StatelessWidget {
  const ConfirmEmailScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConfirmEmailController(
        email: email,
        confirmEmail: context.read<ConfirmEmail>(),
        resendConfirmation: context.read<ResendConfirmation>(),
        initialCooldownSeconds: _resendCooldownSeconds,
      ),
      child: const _ConfirmEmailView(),
    );
  }
}

class _ConfirmEmailView extends StatefulWidget {
  const _ConfirmEmailView();

  @override
  State<_ConfirmEmailView> createState() => _ConfirmEmailViewState();
}

class _ConfirmEmailViewState extends State<_ConfirmEmailView> {
  final _codeFieldKey = GlobalKey<SkyCodeFieldState>();
  bool _handledOutcome = false;
  String _code = '';

  // Evita pantalla en negro si no hay nada debajo en el stack (ej.
  // viniendo del registro, que reemplaza la ruta anterior).
  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _handleOutcome(ConfirmEmailController controller) {
    if (_handledOutcome) return;
    if (controller.confirmedUser != null) {
      _handledOutcome = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SkySnackbar.show(
          context,
          'Correo confirmado. Ya puedes iniciar sesión.',
          tone: SkySnackbarTone.success,
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      });
    } else if (controller.alreadyConfirmed) {
      _handledOutcome = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SkySnackbar.show(context, 'El correo ya está confirmado');
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      });
    } else if (controller.errorMessage != null) {
      _codeFieldKey.currentState?.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ConfirmEmailController>();
    _handleOutcome(controller);

    final colors = context.skyColors;
    final typography = context.skyTypography;

    return SkyScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkyIconButton(
          icon: SkyIconType.arrowLeft,
          tooltip: 'Volver',
          onPressed: () => _goBack(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkyFadeSlideIn(
                        child: SkyIcon(
                          SkyIconType.mail,
                          size: 40,
                          color: colors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: SkySpacing.md),
                      SkyFadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        child: Text(
                          'Revisa tu correo',
                          style: typography.display,
                        ),
                      ),
                      const SizedBox(height: SkySpacing.xxs),
                      SkyFadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        child: RichText(
                          text: TextSpan(
                            style: typography.body.copyWith(
                              color: colors.subtle,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Enviamos un código de 5 caracteres a ',
                              ),
                              TextSpan(
                                text: controller.email,
                                style: typography.bodyStrong.copyWith(
                                  color: colors.ink,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '. El código vence en 30 minutos y admite hasta 5 intentos.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: SkySpacing.xl),
                      SkyFadeSlideIn(
                        delay: const Duration(milliseconds: 140),
                        child: SkyShake(
                          shakeKey: controller.shakeCount,
                          child: Center(
                            child: SkyCodeField(
                              key: _codeFieldKey,
                              length: 5,
                              enabled: !controller.isVerifying,
                              autofocus: true,
                              onChanged: (value) =>
                                  setState(() => _code = value),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: SkySpacing.md),
                      SkyButton(
                        label: 'Verificar correo',
                        expand: true,
                        loading: controller.isVerifying,
                        onPressed: _code.length == 5
                            ? () => controller.verify(_code)
                            : null,
                      ),
                      const SizedBox(height: SkySpacing.md),
                      AnimatedSwitcher(
                        duration: SkyMotion.base,
                        child: controller.errorMessage == null
                            ? const SizedBox.shrink()
                            : Padding(
                                key: ValueKey(controller.errorMessage),
                                padding: const EdgeInsets.only(
                                  bottom: SkySpacing.md,
                                ),
                                child: SkyInlineAlert(
                                  message: controller.errorMessage!,
                                ),
                              ),
                      ),
                      if (controller.isVerifying)
                        const Padding(
                          padding: EdgeInsets.only(bottom: SkySpacing.md),
                          child: Center(
                            child: SkySkeleton(height: 4, width: 120),
                          ),
                        ),
                      SkyFadeSlideIn(
                        delay: const Duration(milliseconds: 180),
                        child: ResendCodeButton(
                          cooldownSeconds: controller.cooldownSeconds,
                          totalSeconds: _resendCooldownSeconds,
                          isResending: controller.isResending,
                          onPressed: () => controller.resend(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
