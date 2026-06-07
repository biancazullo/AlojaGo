import 'package:flutter/material.dart';

Color _regBackground(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF101620)
    : const Color(0xFFF8F4EC);
Color _regSurface(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF16212A)
    : const Color(0xFFFFFFFF);
Color _regSurfaceVariant(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF24343F)
    : const Color(0xFFEDE8DA);
Color _regPrimary(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF5DBEAA)
    : const Color(0xFF1B4332);
Color _regPrimaryLight(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF8CE1C7)
    : const Color(0xFF2D6A4F);
Color _regOnSurface(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFFFFFFF)
    : const Color(0xFFFFFFFF);
Color _regOnSurfaceVariant(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFB1C6D1)
    : const Color(0xFF2D6A4F);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: _regSurface(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _regSurfaceVariant(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _regPrimary(context)),
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _regBackground(context),
      appBar: AppBar(
        backgroundColor: _regBackground(context),
        elevation: 0,
        iconTheme: IconThemeData(color: _regPrimary(context)),
        title: Text(
          'Crear cuenta',
          style: TextStyle(
            color: _regPrimary(context),
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _regSurface(context),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _regPrimary(context).withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Regístrate ahora',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _regPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu cuenta para comenzar a reservar alojamientos en Venezuela.',
                    style: TextStyle(
                      color: _regOnSurfaceVariant(context),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Nombre completo',
                          hint: 'Escribe tu nombre',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          label: 'Teléfono',
                          hint: '+58 412 1234567',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu teléfono';
                            }
                            if (!RegExp(r'^[0-9+\s-]{7,20}$').hasMatch(value.trim())) {
                              return 'Teléfono no válido';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedGender,
                            decoration: InputDecoration(
                              labelText: 'Sexo',
                              filled: true,
                              fillColor: _regSurface(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: _regSurfaceVariant(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: _regPrimary(context)),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                              DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                              DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecciona tu sexo';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: _birthdayController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Fecha de nacimiento',
                              hintText: 'DD/MM/AAAA',
                              filled: true,
                              fillColor: _regSurface(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: _regSurfaceVariant(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: _regPrimary(context)),
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: _regPrimaryLight(context),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Selecciona tu fecha de nacimiento';
                              }
                              return null;
                            },
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(1995, 1, 1),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: Theme.of(context).brightness == Brightness.dark
                                          ? ColorScheme.dark(primary: _regPrimary(context))
                                          : ColorScheme.light(primary: _regPrimary(context)),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                _birthdayController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                              }
                            },
                          ),
                        ),
                        _buildTextField(
                          label: 'Correo electrónico',
                          hint: 'usuario@correo.unimet.edu.ve',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            
                            // Normalizamos el texto quitando espacios y pasando a minúsculas
                            final email = value.trim().toLowerCase();
                            
                            // 1. Valida el formato de correo electrónico
                            if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) {
                              return 'Correo no válido';
                            }
                            
                            // 2. Bloqueo obligatorio a dominios fuera de UNIMET
                            if (!email.endsWith('@correo.unimet.edu.ve')) {
                              return 'Solo se permiten correos @correo.unimet.edu.ve';
                            }
                            
                            return null; // Todo en orden
                          },
                        ),
                        _buildTextField(
                          label: 'Contraseña',
                          hint: 'Al menos 8 caracteres',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: _regPrimaryLight(context),
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa una contraseña';
                            }
                            if (value.length < 8) {
                              return 'La contraseña debe tener al menos 8 caracteres';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          label: 'Confirmar contraseña',
                          hint: 'Repite tu contraseña',
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          suffix: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                              color: _regPrimaryLight(context),
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirm = !_obscureConfirm);
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirma tu contraseña';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Al registrarte aceptas los términos y condiciones.',
                            style: TextStyle(
                              color: _regOnSurfaceVariant(context),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                final profileData = {
                                  'name': _nameController.text.trim(),
                                  'email': _emailController.text.trim(),
                                  'phone': _phoneController.text.trim(),
                                  'gender': _selectedGender ?? '',
                                  'birthday': _birthdayController.text.trim(),
                                };
                                Navigator.of(context).pop(profileData);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _regPrimary(context),
                              foregroundColor: _regOnSurface(context),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            '¿Ya tienes cuenta? Iniciar sesión',
                            style: TextStyle(
                              color: _regPrimaryLight(context),
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: _regSurface(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _regSurfaceVariant(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _regPrimary(context)),
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _regBackground(context),
      appBar: AppBar(
        backgroundColor: _regBackground(context),
        elevation: 0,
        iconTheme: IconThemeData(color: _regPrimary(context)),
        title: Text(
          'Iniciar sesión',
          style: TextStyle(
            color: _regPrimary(context),
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _regSurface(context),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _regPrimary(context).withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido de nuevo',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _regPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia sesión para continuar con tus reservas y ofertas especiales.',
                    style: TextStyle(
                      color: _regOnSurfaceVariant(context),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Correo electrónico',
                          hint: 'usuario@correo.unimet.edu.ve',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            
                            // Convertimos a minúsculas y limpiamos espacios para evitar errores de tipeo
                            final email = value.trim().toLowerCase();
                            
                            // 1. Validación de estructura general de un email
                            if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) {
                              return 'Correo no válido';
                            }
                            
                            // 2. Validación estricta del dominio UNIMET (Afecta tanto a Login como a Registro)
                            if (!email.endsWith('@correo.unimet.edu.ve')) {
                              return 'Solo se permiten correos @correo.unimet.edu.ve';
                            }
                            
                            return null; // El correo es válido y pertenece a la UNIMET
                          },
                        ),
                        _buildTextField(
                          label: 'Contraseña',
                          hint: 'Tu contraseña',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: _regPrimaryLight(context),
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                final email = _emailController.text.trim();
                                final profileData = {
                                  'name': email.contains('@') ? email.split('@').first : email,
                                  'email': email,
                                };
                                Navigator.of(context).pop(profileData);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _regPrimary(context),
                              foregroundColor: _regOnSurface(context),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            '¿No tienes cuenta? Registrarse',
                            style: TextStyle(
                              color: _regPrimaryLight(context),
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}