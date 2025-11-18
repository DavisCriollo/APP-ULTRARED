import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/auth/presentation/providers/login_form_provider.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/main.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: GeometricalBackground(
              child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 45),
            // Icon Banner
            SizedBox(
              width: responsive.wScreen(40),
              child: Image.asset(
                'assets/images/logoNeitor.png',
                fit: BoxFit.cover,
              ),
            ),
            // const Icon(
            //   Icons.production_quantity_limits_rounded,
            //
            //   size: 100,
            // ),
            const SizedBox(height: 45),

            Container(
              height: size.height - 260, // 80 los dos sizebox y 100 el ícono
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(100)),
              ),
              child: const _LoginForm(),
            )
          ],
        ),
      ))),
    );
  }
}

class _LoginForm extends ConsumerWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    final responsive = Responsive.of(context);
    ref.listen(
      authProvider,
      (_, next) {
        if (next.errorMessage!.isEmpty) return;
        NotificationsService.show(
            context, next.errorMessage!, SnackbarCategory.error);
      },
    );
    final textStyles = Theme.of(context).textTheme;
    if (loginForm.isLoadingData) {
      return const FullScreenLoader();
    }
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      child: Column(
        children: [
          const Spacer(),
          Text('Login', style: textStyles.titleLarge),
          const Spacer(),
          CustomInputField(
            label: 'Empresa',
            autofocus: true,
            toUpperCase: true,
            initialValue: loginForm.empresa.value,
            onChanged: ref.read(loginFormProvider.notifier).onEmpresaChange,
            errorMessage:
                loginForm.isFormPosted ? loginForm.empresa.errorMessage : null,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: 'Usuario',
            initialValue: loginForm.usuario.value,
            onChanged: ref.read(loginFormProvider.notifier).onUsuarioChange,
            errorMessage:
                loginForm.isFormPosted ? loginForm.usuario.errorMessage : null,
          ),

          // CustomTextFormField(
          //   label: 'Usuario',
          //   onChanged: ref.read(loginFormProvider.notifier).onUsuarioChange,
          //   errorMessage:
          //       loginForm.isFormPosted ? loginForm.usuario.errorMessage : null,
          // ),
          const SizedBox(height: 30),
          // CustomTextFormField(
          //   initialValue: loginForm.password.value,
          //   label: 'Contraseña',
          //   obscureText: true,
          //   onChanged: ref.read(loginFormProvider.notifier).onPasswordChange,
          //   onFieldSubmitted: (_) =>
          //       ref.read(loginFormProvider.notifier).onFormSubmit(),
          //   errorMessage:
          //       loginForm.isFormPosted ? loginForm.password.errorMessage : null,
          // ),
          CustomInputField(
            initialValue: loginForm.password.value,
            label: 'Contraseña',
            obscureText: true,
            onChanged: ref.read(loginFormProvider.notifier).onPasswordChange,
            onFieldSubmitted: (_) =>
                ref.read(loginFormProvider.notifier).onFormSubmit(),
            errorMessage:
                loginForm.isFormPosted ? loginForm.password.errorMessage : null,
          ),
          const SizedBox(height: 30),
          SizedBox(
              width: responsive.wScreen(70),
              // height: responsive.wScreen(40),
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(colors.primary),
                  foregroundColor: WidgetStateProperty.all<Color>(colors.primary.contrastText),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          15), // Ajusta el valor según lo redondeado que quieras el botón
                    ),
                  ),
                ),
                onPressed: loginForm.isPosting
                    ? null
                    : ref.read(loginFormProvider.notifier).onFormSubmit,
                child: Text(
                  'Ingresar',
                  style: TextStyle(
                    fontSize: responsive.iScreen(2.5),
                  ),
                ),
              )),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Recuerdame'),
                  Checkbox(
                    value: loginForm.rememberMe,
                    onChanged:
                        ref.read(loginFormProvider.notifier).onRememberMeChange,
                  )
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  )
                ],
              )
            ],
          ),
 
          Text(
            'Ver: 0.5.0',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
