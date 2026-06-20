// lib/registrase.dart
// Registro con selección de rol + verificación de PIN para operador/admin
// Mantiene el estilo Figma (kFigma*) original del proyecto.

import 'package:flutter/material.dart';

import 'data/repositories/auth_repository.dart';
import 'data/services/pin_service.dart';
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
  const RegisterPage({super.key, this.authRepository, this.onLoginSuccess});
  final AuthRepository? authRepository;
  final Function(Map<String, String>)? onLoginSuccess;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Paso 1: elegir rol. Paso 2: formulario. Paso 3: PIN (si aplica).
  int _step = 1;
  UserRole _selectedRole = UserRole.traveler;

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
  final _pinService = PinService();

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

  // ── Validación del formulario → avanza al PIN o registra directo ──
  void _onFormNext() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == UserRole.operator || _selectedRole == UserRole.admin) {
      setState(() => _step = 3);
    } else {
      _doRegister(pin: null);
    }
  }

  // ── Registro final ─────────────────────────────────────────────────────
  Future<void> _doRegister({required String? pin}) async {
    if (_selectedRole != UserRole.traveler && pin != null) {
      final isAdmin = _selectedRole == UserRole.admin;
      final valid = await _pinService.verifyPin(
        inputPin: pin,
        isAdmin: isAdmin,
      );
      if (!valid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN incorrecto. Intenta de nuevo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final user = await _viewModel.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      gender: _selectedGender ?? '',
      birthday: _birthdayController.text.trim(),
      role: _selectedRole,
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
    final userData = user.toProfileMap().map((key, value) => MapEntry(key, value.toString()));
    
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!(userData);
    }
    
    navigator.popUntil((route) => route.isFirst);
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
              child: _step == 1
                  ? _RoleSelector(
                      key: const ValueKey('step1'),
                      selectedRole: _selectedRole,
                      onRoleSelected: (role) {
                        setState(() {
                          _selectedRole = role;
                          _step = 2;
                        });
                      },
                    )
                  : _step == 2
                  ? _RegistrationForm(
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
                      selectedRole: _selectedRole,
                      onGenderChanged: (v) =>
                          setState(() => _selectedGender = v),
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onToggleConfirm: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      onBack: () => setState(() => _step = 1),
                      onSubmit: _onFormNext,
                      authRepository: widget.authRepository,
                      onLoginSuccess: widget.onLoginSuccess,
                    )
                  : _PinEntryStep(
                      key: const ValueKey('step3'),
                      isAdmin: _selectedRole == UserRole.admin,
                      isLoading: _viewModel.isLoading,
                      onBack: () => setState(() => _step = 2),
                      onSubmit: (pin) => _doRegister(pin: pin),
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

// ── PASO 1: Selección de rol ───────────────────────────────────────────────
class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Registro',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: kFigmaTextDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Selecciona cómo quieres registrarte',
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 36),
        _RoleCard(
          icon: Icons.backpack_outlined,
          title: 'Viajero',
          description:
              'Busca y reserva alojamientos, deja reseñas y gestiona tus viajes.',
          color: const Color(0xFF52B788),
          onTap: () => onRoleSelected(UserRole.traveler),
        ),
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.business_outlined,
          title: 'Operador Turístico',
          description:
              'Publica y gestiona ofertas de hospedaje. Requiere PIN de acceso.',
          color: const Color(0xFFD4A853),
          onTap: () => onRoleSelected(UserRole.operator),
        ),
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Administrador',
          description:
              'Acceso completo a gestión de plataforma. Requiere PIN de acceso.',
          color: const Color(0xFFBF6B3D),
          onTap: () => onRoleSelected(UserRole.admin),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kFigmaInputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kFigmaInputBorder, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kFigmaTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
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
    required this.onLoginSuccess,
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
  final Function(Map<String, String>)? onLoginSuccess;

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
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
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
                        builder: (context) => LoginPage(
                          authRepository: authRepository,
                          onLoginSuccess: onLoginSuccess,
                        ),
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
            value: selectedGender,
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
            validator: (v) =>
                (v == null || v.trim().isEmpty)
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

// ── PASO 3: Verificación de PIN ────────────────────────────────────────────
class _PinEntryStep extends StatefulWidget {
  const _PinEntryStep({
    super.key,
    required this.isAdmin,
    required this.isLoading,
    required this.onBack,
    required this.onSubmit,
  });

  final bool isAdmin;
  final bool isLoading;
  final VoidCallback onBack;
  final ValueChanged<String> onSubmit;

  @override
  State<_PinEntryStep> createState() => _PinEntryStepState();
}

class _PinEntryStepState extends State<_PinEntryStep> {
  final _pinController = TextEditingController();
  bool _obscurePin = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleName =
        widget.isAdmin ? 'Administrador' : 'Operador Turístico';
    final roleColor =
        widget.isAdmin ? const Color(0xFFBF6B3D) : const Color(0xFFD4A853);
    final roleIcon = widget.isAdmin
        ? Icons.admin_panel_settings_outlined
        : Icons.business_outlined;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'Verificación de PIN',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kFigmaTextDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(roleIcon, color: roleColor, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          'Acceso como $roleName',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kFigmaTextDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa el PIN de acceso para este rol.\nContacta al administrador si no lo tienes.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 32),
        _figmaField(
          label: 'PIN de acceso',
          hint: '••••',
          controller: _pinController,
          obscureText: _obscurePin,
          keyboardType: TextInputType.number,
          suffix: IconButton(
            icon: Icon(
              _obscurePin ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
            onPressed: () => setState(() => _obscurePin = !_obscurePin),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isLoading
                ? null
                : () {
                    final pin = _pinController.text.trim();
                    if (pin.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ingresa el PIN'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    widget.onSubmit(pin);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: kFigmaBtnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              widget.isLoading ? 'Verificando...' : 'Verificar y Registrar',
              style: const TextStyle(
                color: kFigmaTextDark,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── PÁGINA DE LOGIN ────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authRepository, this.onLoginSuccess});
  final AuthRepository? authRepository;
  final Function(Map<String, String>)? onLoginSuccess;

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
                          if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
                              .hasMatch(email)) {
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
                                        false)) return;
                                    final messenger =
                                        ScaffoldMessenger.of(context);
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
                                final rawMap = user.toProfileMap();
                                final Map<String, String> userData = {
                                  'id': (rawMap['id'] ?? '').toString(),
                                  'name': (rawMap['name'] ?? _emailController.text.split('@')[0]).toString(),
                                  'email': (rawMap['email'] ?? _emailController.text.trim()).toString(),
                                  'phone': (rawMap['phone'] ?? '').toString(),
                                  'gender': (rawMap['gender'] ?? '').toString(),
                                  'birthday': (rawMap['birthday'] ?? '').toString(),
                                  'role': (rawMap['role'] ?? 'traveler').toString(),
                                };

                                if (widget.onLoginSuccess != null) {
                                  widget.onLoginSuccess!(userData);
                                }
                                
                                navigator.popUntil((route) => route.isFirst);
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(
                                  authRepository: widget.authRepository,
                                  onLoginSuccess: (datosRegistro) {
                                    widget.onLoginSuccess?.call(datosRegistro);
                                    Navigator.of(context).pop();
                                  },
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