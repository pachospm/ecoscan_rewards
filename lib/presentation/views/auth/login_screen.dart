import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/constants/app_constants.dart';
import 'package:ecoscan_rewards/core/routes/app_routes.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      final role = authVM.currentUser?.role;
      if (role == AppConstants.rolAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.recyclerHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Logo
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 100),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryGreenLight,
                          AppTheme.accentTeal,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreenLight.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.recycling,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Título
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Inicia sesión para continuar reciclando',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // Formulario
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 260),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!v.contains('@')) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppTheme.textSecondary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      // Error
                      Consumer<AuthViewModel>(
                        builder: (_, vm, __) {
                          if (vm.errorMessage == null) return const SizedBox();
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.errorRed.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorRed,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    vm.errorMessage!,
                                    style: const TextStyle(
                                      color: AppTheme.errorRed,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Botón login
                      Consumer<AuthViewModel>(
                        builder: (_, vm, __) {
                          return ElevatedButton(
                            onPressed: vm.isLoading ? null : _login,
                            child: vm.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Iniciar sesión'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Credenciales demo
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 360),
                child: _DemoCredentials(
                  onSelectAdmin: () {
                    _emailController.text = 'admin@ecoscan.com';
                    _passwordController.text = 'admin123';
                  },
                  onSelectRecycler: () {
                    _emailController.text = 'maria@ecoscan.com';
                    _passwordController.text = 'recycler123';
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoCredentials extends StatelessWidget {
  final VoidCallback onSelectAdmin;
  final VoidCallback onSelectRecycler;

  const _DemoCredentials({
    required this.onSelectAdmin,
    required this.onSelectRecycler,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 15, color: AppTheme.textSecondary),
              SizedBox(width: 6),
              Text(
                'Credenciales de demo',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CredentialChip(
                  label: 'Admin',
                  onTap: onSelectAdmin,
                  color: AppTheme.accentAmber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CredentialChip(
                  label: 'Reciclador',
                  onTap: onSelectRecycler,
                  color: AppTheme.primaryGreenLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CredentialChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _CredentialChip({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
