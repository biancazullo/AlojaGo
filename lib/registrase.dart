// lib/registrase.dart
// Registro normal de viajeros.
// Mantiene el estilo Figma (kFigma*) original del proyecto.

import 'package:flutter/material.dart';

import 'data/repositories/auth_repository.dart';
import 'domain/models/app_user.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';

// ── Paleta Figma original ──────────────────────────────────────────────────
const Color kFigmaBg = Color(0xFFF4F3EB);
const Color kFigmaAppBarBg = Color(0xFFEBEADB);
const Color kFigmaInputBg = Color(0xFFFFFFFF);
const Color kFigmaInputBorder = Color(0xFFCCCCCC);
const Color kFigmaBtnPrimary = Color(0xFFD6D6D6);
const Color kFigmaTextDark = Color(0xFF111111);
const Color kEmerald = Color(0xFF1B4332);
const Color kEmeraldMid = Color(0xFF2D6A4F);

// ── PÁGINA DE REGISTRO ─────────────────────────────────────────────────────
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.authRepository});
  final AuthRepository? authRepository;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final AuthViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel(
      authRepository: widget.authRepository ?? FirebaseAuthRepository(),
    );
    _viewModel.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _viewModel.removeListener(_rebuild);
    _viewModel.dispose();
    super.dispose();
  }

  // ── Validación del formulario y registro ──
  void _onFormNext() {
    if (!_formKey.currentState!.validate()) return;
    _doRegister();
  }

  // ── Registro final ─────────────────────────────────────────────────────
  Future<void> _doRegister() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final user = await _viewModel.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      gender: _selectedGender ?? '',
      birthday: _birthdayController.text.trim(),
      role: UserRole.traveler,
    );

    if (!mounted) return;
    if (user == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'No se pudo crear la cuenta',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    navigator.pop(user.toProfileMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFigmaBg,
      appBar: _buildAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _RegistrationForm(
                key: const ValueKey('step2'),
                formKey: _formKey,
                nameController: _nameController,
                phoneController: _phoneController,
                emailController: _emailController,
                birthdayController: _birthdayController,
                passwordController: _passwordController,
                confirmController: _confirmController,
                selectedGender: _selectedGender,
                obscurePassword: _obscurePassword,
                obscureConfirm: _obscureConfirm,
                isLoading: _viewModel.isLoading,
                selectedRole: UserRole.traveler,
                onGenderChanged: (v) => setState(() => _selectedGender = v),
                onTogglePassword: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onToggleConfirm: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                onBack: () => Navigator.of(context).pop(),
                onSubmit: _onFormNext,
                authRepository: widget.authRepository,
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 65,
      backgroundColor: kFigmaAppBarBg,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 24,
      shape: const Border(
        bottom: BorderSide(color: Color(0xFFE2E1D3), width: 1.5),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            'https://i.postimg.cc/Zn66zqnm/Logo-aloja-en-png-sin-fondo.png',
            height: 60,
            fit: BoxFit.contain,
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kFigmaInputBorder),
              backgroundColor: kFigmaInputBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Inicio',
              style: TextStyle(
                color: kFigmaTextDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PASO 2: Formulario de datos personales ─────────────────────────────────
class _RegistrationForm extends StatelessWidget {
  const _RegistrationForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.birthdayController,
    required this.passwordController,
    required this.confirmController,
    required this.selectedGender,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.isLoading,
    required this.selectedRole,
    required this.onGenderChanged,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onBack,
    required this.onSubmit,
    required this.authRepository,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController birthdayController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String? selectedGender;
  final bool obscurePassword;
  final bool obscureConfirm;
  final bool isLoading;
  final UserRole selectedRole;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final AuthRepository? authRepository;

  String get _roleName {
    switch (selectedRole) {
      case UserRole.operator:
        return 'Operador Turístico';
      case UserRole.admin:
        return 'Administrador';
      default:
        return 'Viajero';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'Registro · $_roleName',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kFigmaTextDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _figmaField(
                label: 'Nombre de Usuario',
                hint: 'Escribe tu nombre completo',
                controller: nameController,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Por favor ingresa tu nombre'
                    : null,
              ),
              _figmaField(
                label: 'Teléfono',
                hint: '+58 412 1234567',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa tu teléfono';
                  }
                  if (!RegExp(r'^[0-9+\s-]{7,20}$').hasMatch(v.trim())) {
                    return 'Teléfono no válido';
                  }
                  return null;
                },
              ),
              _genderDropdown(context),
              _birthdayField(context),
              _figmaField(
                label: 'Correo',
                hint: 'usuario@correo.unimet.edu.ve',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                  final email = v.trim().toLowerCase();
                  if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) {
                    return 'Correo no válido';
                  }
                  if (!email.endsWith('@correo.unimet.edu.ve')) {
                    return 'Solo se permiten correos @correo.unimet.edu.ve';
                  }
                  return null;
                },
              ),
              _figmaField(
                label: 'Contraseña',
                hint: 'Al menos 8 caracteres',
                controller: passwordController,
                obscureText: obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: onTogglePassword,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                  if (v.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  return null;
                },
              ),
              _figmaField(
                label: 'Confirmar Contraseña',
                hint: 'Repite tu contraseña',
                controller: confirmController,
                obscureText: obscureConfirm,
                suffix: IconButton(
                  icon: Icon(
                    obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: onToggleConfirm,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                  if (v != passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: kFigmaInputBorder, thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 120),
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.g_mobiledata,
                          size: 26,
                          color: Color.fromARGB(255, 82, 192, 255),
                        ),
                        label: const Text(
                          'Google',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: kFigmaTextDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: kFigmaInputBg,
                          side: const BorderSide(color: kFigmaInputBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kFigmaBtnPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      isLoading ? 'Procesando...' : 'Continuar',
                      style: const TextStyle(
                        color: kFigmaTextDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginPage(authRepository: authRepository),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: '¿Ya tienes una cuenta en Aloja? ',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Iniciar Sesión',
                          style: TextStyle(
                            color: kFigmaTextDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sexo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kFigmaTextDark,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: selectedGender,
            style: const TextStyle(fontSize: 14, color: kFigmaTextDark),
            decoration: _inputDecoration(),
            items: const [
              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
              DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
              DropdownMenuItem(value: 'Otro', child: Text('Otro')),
            ],
            onChanged: onGenderChanged,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Selecciona tu sexo' : null,
          ),
        ],
      ),
    );
  }

  Widget _birthdayField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fecha de nacimiento',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kFigmaTextDark,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: birthdayController,
            readOnly: true,
            style: const TextStyle(fontSize: 14, color: kFigmaTextDark),
            decoration: _inputDecoration(
              hint: 'DD/MM/AAAA',
              suffix: const Icon(
                Icons.calendar_today,
                color: kFigmaTextDark,
                size: 18,
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Selecciona tu fecha de nacimiento'
                : null,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime(1995, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                birthdayController.text =
                    '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
              }
            },
          ),
        ],
      ),
    );
  }
}

Widget _figmaField({
  required String label,
  required String hint,
  required TextEditingController controller,
  bool obscureText = false,
  Widget? suffix,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kFigmaTextDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: _inputDecoration(hint: hint, suffix: suffix),
        ),
      ],
    ),
  );
}

InputDecoration _inputDecoration({String? hint, Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
    filled: true,
    fillColor: kFigmaInputBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: kFigmaInputBorder, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: kFigmaTextDark, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    suffixIcon: suffix,
  );
}

// ── PÁGINA DE LOGIN ────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authRepository});
  final AuthRepository? authRepository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthViewModel _viewModel;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel(
      authRepository: widget.authRepository ?? FirebaseAuthRepository(),
    );
    _viewModel.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.removeListener(_rebuild);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFigmaBg,
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: kFigmaAppBarBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 24,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E1D3), width: 1.5),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.network(
              'https://i.postimg.cc/Zn66zqnm/Logo-aloja-en-png-sin-fondo.png',
              height: 60,
              fit: BoxFit.contain,
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kFigmaInputBorder),
                backgroundColor: kFigmaInputBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Inicio',
                style: TextStyle(
                  color: kFigmaTextDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Inicio de Sesión',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kFigmaTextDark,
                  ),
                ),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _figmaField(
                        label: 'Correo electrónico',
                        hint: 'usuario@correo.unimet.edu.ve',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          final email = v.trim().toLowerCase();
                          if (!RegExp(
                            r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
                          ).hasMatch(email)) {
                            return 'Correo no válido';
                          }
                          if (!email.endsWith('@correo.unimet.edu.ve')) {
                            return 'Solo se permiten correos @correo.unimet.edu.ve';
                          }
                          return null;
                        },
                      ),
                      _figmaField(
                        label: 'Contraseña',
                        hint: 'Tu contraseña',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black54,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Ingresa tu contraseña'
                            : null,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: kFigmaInputBorder, thickness: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 120),
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.g_mobiledata,
                                  size: 26,
                                  color: Color.fromARGB(255, 1, 151, 197),
                                ),
                                label: const Text(
                                  'Google',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: kFigmaTextDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: kFigmaInputBg,
                                  side: const BorderSide(
                                    color: kFigmaInputBorder,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _viewModel.isLoading
                                ? null
                                : () async {
                                    if (!(_formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    final navigator = Navigator.of(context);
                                    final user = await _viewModel.login(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    );
                                    if (!mounted) return;
                                    if (user == null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            _viewModel.errorMessage ??
                                                'No se pudo iniciar sesion',
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }
                                    navigator.pop(user.toProfileMap());
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kFigmaBtnPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                            child: Text(
                              _viewModel.isLoading
                                  ? 'Ingresando...'
                                  : 'Iniciar Sesión',
                              style: const TextStyle(
                                color: kFigmaTextDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(
                                  authRepository: widget.authRepository,
                                ),
                              ),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: '¿No tienes una cuenta en Aloja? ',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Regístrate',
                                  style: TextStyle(
                                    color: kFigmaTextDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
