import 'package:flutter/material.dart';

Color _profileBackground(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF101620)
    : const Color(0xFFF8F4EC);
Color _profileSurface(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF16212A)
    : const Color(0xFFFFFFFF);
Color _profileSurfaceVariant(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF24343F)
    : const Color(0xFFEDE8DA);
Color _profilePrimary(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF5DBEAA)
    : const Color(0xFF1B4332);
Color _profilePrimaryLight(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF8CE1C7)
    : const Color(0xFF2D6A4F);
Color _profileOnSurface(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFFFFFFF)
    : const Color(0xFF1B4332);
Color _profileOnSurfaceVariant(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFB1C6D1)
    : const Color(0xFF2D6A4F);

class ProfilePage extends StatefulWidget {
  final Map<String, String> profile;

  const ProfilePage({super.key, required this.profile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthdayController;
  String? _selectedGender;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile['name'] ?? '');
    _emailController = TextEditingController(text: widget.profile['email'] ?? '');
    _phoneController = TextEditingController(text: widget.profile['phone'] ?? '');
    _birthdayController = TextEditingController(text: widget.profile['birthday'] ?? '');
    _selectedGender = widget.profile['gender']?.isNotEmpty == true ? widget.profile['gender'] : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
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
          fillColor: _profileSurface(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _profileSurfaceVariant(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _profilePrimary(context)),
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _profileBackground(context),
      appBar: AppBar(
        backgroundColor: _profileBackground(context),
        elevation: 0,
        iconTheme: IconThemeData(color: _profilePrimary(context)),
        title: Text(
          'Mi perfil',
          style: TextStyle(
            color: _profilePrimary(context),
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
                color: _profileSurface(context),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _profilePrimary(context).withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edita tu información',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _profilePrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Actualiza tu nombre, correo y datos de contacto.',
                    style: TextStyle(
                      color: _profileOnSurfaceVariant(context),
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
                          hint: 'Tu nombre completo',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu nombre';
                            }
                            return null;
                          },
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
                            
                            // Convertimos a minúsculas y limpiamos espacios vacíos
                            final email = value.trim().toLowerCase();
                            
                            // 1. Validación de formato de correo general
                            if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) {
                              return 'Correo no válido';
                            }
                            
                            // 2. Validación estricta del dominio UNIMET
                            if (!email.endsWith('@correo.unimet.edu.ve')) {
                              return 'Solo se permiten correos @correo.unimet.edu.ve';
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
                            value: _selectedGender,
                            decoration: InputDecoration(
                              labelText: 'Sexo',
                              filled: true,
                              fillColor: _profileSurface(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: _profileSurfaceVariant(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: _profilePrimary(context)),
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
                              fillColor: _profileSurface(context),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: _profileSurfaceVariant(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: _profilePrimary(context)),
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: _profilePrimaryLight(context),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Selecciona tu fecha de nacimiento';
                              }
                              return null;
                            },
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.tryParse(_birthdayController.text.replaceAll('/', '-')) ?? DateTime(1995, 1, 1),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: Theme.of(context).brightness == Brightness.dark
                                          ? ColorScheme.dark(primary: _profilePrimary(context))
                                          : ColorScheme.light(primary: _profilePrimary(context)),
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
                        const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Valida el formulario antes de salir y devolver los datos actualizados
                                if (_formKey.currentState?.validate() ?? false) {
                                  Navigator.of(context).pop({
                                    'name': _nameController.text.trim(),
                                    'email': _emailController.text.trim(),
                                    'phone': _phoneController.text.trim(),
                                    'gender': _selectedGender ?? '',
                                    'birthday': _birthdayController.text.trim(),
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                // Forzamos un fondo verde oscuro visible para asegurar contraste
                                backgroundColor: const Color(0xFF2D6A4F), 
                                // Forzamos que el color base de los elementos del botón sea blanco
                                foregroundColor: Colors.white, 
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              // Evaluamos si el campo de texto del nombre ya tiene información
                              child: Text(
                                _nameController.text.isNotEmpty ? 'Guardar cambios' : 'Volver',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white, // Asegura doblemente las letras blancas
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
      ),
    );
  }
}