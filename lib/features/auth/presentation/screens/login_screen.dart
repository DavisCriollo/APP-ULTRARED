import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/config/provider/app_version_provider.dart';
import 'package:ultrared/config/theme/app_theme.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/auth/presentation/providers/login_form_provider.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/main.dart';

/// Color de marca puro (sin tonalización de Material).
const Color _brandColor = AppTheme.basePrimaryColor;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: colors.surface,
        body: const _LoginView(),
      ),
    );
  }
}

class _LoginView extends ConsumerWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    final loginForm = ref.watch(loginFormProvider);

    // Escucha de errores de autenticación (lógica original intacta)
    ref.listen(
      authProvider,
      (_, next) {
        if (next.errorMessage!.isEmpty) return;
        NotificationsService.show(
            context, next.errorMessage!, SnackbarCategory.error);
      },
    );

    if (loginForm.isLoadingData) {
      return const FullScreenLoader();
    }

    // Límite de ancho para que en tablet no se estire el formulario.
    final cardMaxWidth = responsive.isTablet
        ? responsive.readableContentWidth * 0.62
        : double.infinity;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          const _BrandHeader(),
          Transform.translate(
            offset: Offset(0, -responsive.h(36)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.w(22)),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardMaxWidth),
                  child: const _LoginCard(),
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.h(10)),
          // Logo pequeño junto a la versión, debajo del formulario.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logoNeitor.png',
                height: responsive.h(35),
                fit: BoxFit.contain,
              ),
              SizedBox(width: responsive.w(8)),
              AppVersionText(
                prefix: 'Versión ',
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.4),
                  fontSize: responsive.sp(20),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(18)),
        ],
      ),
    );
  }
}

/// Cabecera con la marca: color primario puro, logo y bienvenida.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final onBrand = _brandColor.contrastText;

    return Container(
      width: double.infinity,
      height: responsive.hScreen(34),
      decoration: BoxDecoration(
        color: _brandColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(responsive.w(44)),
        ),
        boxShadow: [
          BoxShadow(
            color: _brandColor.withValues(alpha: 0.35),
            blurRadius: responsive.w(24),
            offset: Offset(0, responsive.h(10)),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: responsive.h(8)),
            Container(
              padding: EdgeInsets.all(responsive.w(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: responsive.w(16),
                    offset: Offset(0, responsive.h(6)),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logos/ur_logo.png',
                width: responsive.w(76),
                height: responsive.w(76),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: responsive.h(20)),
            Text(
              'Bienvenido',
              style: TextStyle(
                color: onBrand,
                fontSize: responsive.sp(30),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: responsive.h(6)),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta con el formulario. Mantiene toda la lógica original.
class _LoginCard extends ConsumerStatefulWidget {
  const _LoginCard();

  @override
  ConsumerState<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<_LoginCard> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    final loginForm = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);

    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.w(22),
        responsive.h(26),
        responsive.w(22),
        responsive.h(24),
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(responsive.w(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: responsive.w(24),
            offset: Offset(0, responsive.h(10)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Iniciar sesión',
            style: TextStyle(
              color: _brandColor,
              fontSize: responsive.sp(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.h(24)),
          _IconField(
            icon: Icons.business_outlined,
            child: CustomInputField(
              label: 'Empresa',
              autofocus: true,
              toUpperCase: true,
              initialValue: loginForm.empresa.value,
              onChanged: notifier.onEmpresaChange,
              errorMessage: loginForm.isFormPosted
                  ? loginForm.empresa.errorMessage
                  : null,
            ),
          ),
          SizedBox(height: responsive.h(22)),
          _IconField(
            icon: Icons.person_outline,
            child: CustomInputField(
              label: 'Usuario',
              initialValue: loginForm.usuario.value,
              onChanged: notifier.onUsuarioChange,
              errorMessage: loginForm.isFormPosted
                  ? loginForm.usuario.errorMessage
                  : null,
            ),
          ),
          SizedBox(height: responsive.h(22)),
          _IconField(
            icon: Icons.lock_outline,
            child: CustomInputField(
              label: 'Contraseña',
              obscureText: _obscurePassword,
              initialValue: loginForm.password.value,
              onChanged: notifier.onPasswordChange,
              onFieldSubmitted: (_) => notifier.onFormSubmit(),
              errorMessage: loginForm.isFormPosted
                  ? loginForm.password.errorMessage
                  : null,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _brandColor,
                  size: responsive.sp(20),
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.h(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: responsive.w(24),
                    width: responsive.w(24),
                    child: Checkbox(
                      value: loginForm.rememberMe,
                      activeColor: _brandColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(responsive.w(4)),
                      ),
                      onChanged: notifier.onRememberMeChange,
                    ),
                  ),
                  SizedBox(width: responsive.w(8)),
                  Text(
                    'Recuérdame',
                    style: TextStyle(fontSize: responsive.sp(15)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: _brandColor,
                    fontSize: responsive.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(26)),
          SizedBox(
            width: double.infinity,
            height: responsive.h(54),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: _brandColor.contrastText,
                disabledBackgroundColor: _brandColor.withValues(alpha: 0.5),
                elevation: 2,
                shadowColor: _brandColor.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.w(14)),
                ),
              ),
              onPressed: loginForm.isPosting ? null : notifier.onFormSubmit,
              child: loginForm.isPosting
                  ? SizedBox(
                      height: responsive.w(24),
                      width: responsive.w(24),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _brandColor.contrastText,
                      ),
                    )
                  : Text(
                      'Ingresar',
                      style: TextStyle(
                        fontSize: responsive.sp(22),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila que antepone un ícono al campo de texto para un look más pulido.
class _IconField extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _IconField({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: responsive.h(6),
            right: responsive.w(12),
          ),
          child: Icon(icon, color: _brandColor, size: responsive.sp(22)),
        ),
        Expanded(child: child),
      ],
    );
  }
}
