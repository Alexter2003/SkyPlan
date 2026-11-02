import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/navigation/app_drawer.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/domain/usecases/get_account_profile.dart';
import '../../../auth/presentation/state/session_controller.dart';
import '../../domain/usecases/update_profile.dart';
import '../state/profile_controller.dart';

/// Perfil del usuario: usuario y correo de solo lectura, nombre editable.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileController(
        getProfile: context.read<GetAccountProfile>(),
        updateProfile: context.read<UpdateProfile>(),
        onSaved: context.read<SessionController>().updateUser,
      )..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _fillOnce(ProfileController controller) {
    final user = controller.user;
    if (_filled || user == null) return;
    _filled = true;
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
  }

  Future<void> _save(ProfileController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final nothingChanged =
        _firstNameController.text.trim() ==
            (controller.user?.firstName ?? '') &&
        _lastNameController.text.trim() == (controller.user?.lastName ?? '');
    if (nothingChanged) {
      SkySnackbar.show(context, 'No hay cambios que guardar');
      return;
    }

    final saved = await controller.save(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );
    if (!mounted || !saved) return;
    SkySnackbar.show(
      context,
      'Perfil actualizado',
      tone: SkySnackbarTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final typography = context.skyTypography;
    final colors = context.skyColors;
    _fillOnce(controller);

    return SkyScaffold(
      drawer: const AppDrawer(currentRoute: AppRoutes.profile),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => SkyIconButton(
            icon: SkyIconType.menu,
            tooltip: 'Menú',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Mi perfil', style: typography.headline),
      ),
      body: _body(controller, typography, colors),
    );
  }

  Widget _body(
    ProfileController controller,
    SkyTypography typography,
    SkyColors colors,
  ) {
    if (controller.isLoading && controller.user == null) {
      return ListView(
        children: const [
          SkySkeleton(height: 60),
          SizedBox(height: SkySpacing.sm),
          SkySkeleton(height: 60),
          SizedBox(height: SkySpacing.sm),
          SkySkeleton(height: 60),
        ],
      );
    }

    if (controller.loadError != null && controller.user == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkyInlineAlert(message: controller.loadError!),
          const SizedBox(height: SkySpacing.md),
          SkyButton(
            label: 'Reintentar',
            variant: SkyButtonVariant.secondary,
            expand: true,
            onPressed: controller.load,
          ),
        ],
      );
    }

    final user = controller.user!;
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: SkyShake(
          shakeKey: controller.shakeCount,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.saveError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: SkySpacing.md),
                  child: SkyInlineAlert(message: controller.saveError!),
                ),
              SkyTextField(
                key: const ValueKey('profile-username'),
                controller: _usernameController,
                label: 'Nombre de usuario',
                leadingIcon: SkyIconType.user,
                enabled: false,
              ),
              const SizedBox(height: SkySpacing.sm),
              SkyTextField(
                key: const ValueKey('profile-email'),
                controller: _emailController,
                label: 'Correo electrónico',
                leadingIcon: SkyIconType.mail,
                enabled: false,
              ),
              const SizedBox(height: SkySpacing.xxs),
              Text(
                'El usuario, el correo y la contraseña no se pueden editar '
                'desde aquí. Para cambiar tu contraseña usa «Olvidé mi '
                'contraseña» al iniciar sesión.',
                style: typography.caption.copyWith(color: colors.subtle),
              ),
              const SizedBox(height: SkySpacing.lg),
              SkyTextField(
                controller: _firstNameController,
                label: 'Nombre',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                validator: (v) => SkyValidators.personName(
                  v,
                  field: 'El nombre',
                  allowEmpty: (user.firstName ?? '').isEmpty,
                ),
              ),
              const SizedBox(height: SkySpacing.sm),
              SkyTextField(
                controller: _lastNameController,
                label: 'Apellido',
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.familyName],
                validator: (v) => SkyValidators.personName(
                  v,
                  field: 'El apellido',
                  allowEmpty: (user.lastName ?? '').isEmpty,
                ),
              ),
              const SizedBox(height: SkySpacing.xl),
              SkyButton(
                label: 'Guardar cambios',
                expand: true,
                loading: controller.isSaving,
                onPressed: () => _save(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
