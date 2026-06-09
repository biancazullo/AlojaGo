import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Paleta de colores exacta de Figma
const Color kFigmaBg = Color(0xFFF4F3EB);      // Fondo crema claro de la pantalla
const Color kFigmaAppBarBg = Color(0xFFEBEADB); // Barra superior crema ligeramente más oscura
const Color kFigmaInputBg = Color(0xFFFFFFFF);  // Fondo blanco de los inputs
const Color kFigmaInputBorder = Color(0xFFCCCCCC); // Borde gris claro/fino de Figma
const Color kFigmaBtnPrimary = Color(0xFFD6D6D6); // Botón gris de Figma
const Color kFigmaTextDark = Color(0xFF111111);   // Texto casi negro para títulos y botones

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
  Future<void> _signUp() async {
  // 1. Validar formulario
  if (!_formKey.currentState!.validate()) return;

  try {
    // 2. Registro en Auth
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // 3. Guardar en Firestore
    await FirebaseFirestore.instance
        .collection('users')
    .doc(userCredential.user!.uid) // El ID del documento es el UID del usuario
    .set({
      // Guardamos todo el objeto de perfil de una vez
      'profile': {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _selectedGender ?? '',
        'birthday': _birthdayController.text.trim(),
      },
      'createdAt': FieldValue.serverTimestamp(), // Es útil tener esto
    });

    // 4. Si llegó hasta aquí, todo salió bien
    print("¡Registro exitoso!");
  } catch (e) {
    // Si hay un error, aquí lo verás en la consola
    print("Error al registrar: $e");
  }
}


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

  Widget _buildFigmaTextField({
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kFigmaTextDark),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFigmaBg,
      // ── BARRA SUPERIOR AMPLIADA (REGISTRO) ──
      appBar: AppBar(
        toolbarHeight: 65, // Altura ampliada
        backgroundColor: kFigmaAppBarBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 24,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E1D3), width: 1.5), // Línea de segmentación
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Inicio',
                style: TextStyle(color: kFigmaTextDark, fontSize: 13, fontWeight: FontWeight.w600),
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
                  'Registro',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kFigmaTextDark),
                ),
                const SizedBox(height: 28),
                
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFigmaTextField(
                        label: 'Nombre de Usuario',
                        hint: 'Escribe tu nombre completo',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Por favor ingresa tu nombre';
                          return null;
                        },
                      ),
                      _buildFigmaTextField(
                        label: 'Teléfono',
                        hint: '+58 412 1234567',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Ingresa tu teléfono';
                          if (!RegExp(r'^[0-9+\s-]{7,20}$').hasMatch(value.trim())) return 'Teléfono no válido';
                          return null;
                        },
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sexo',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kFigmaTextDark),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              style: const TextStyle(fontSize: 14, color: kFigmaTextDark),
                              decoration: InputDecoration(
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
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                              ],
                              onChanged: (value) => setState(() => _selectedGender = value),
                              validator: (value) => (value == null || value.isEmpty) ? 'Selecciona tu sexo' : null,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha de nacimiento',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kFigmaTextDark),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: TextFormField(
                              controller: _birthdayController,
                              readOnly: true,
                              style: const TextStyle(fontSize: 14, color: kFigmaTextDark),
                              decoration: InputDecoration(
                                hintText: 'DD/MM/AAAA',
                                hintStyle: const TextStyle(color: Colors.black38),
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
                                suffixIcon: const Icon(Icons.calendar_today, color: kFigmaTextDark, size: 18),
                              ),
                              validator: (value) => (value == null || value.trim().isEmpty) ? 'Selecciona tu fecha de nacimiento' : null,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(1995, 1, 1),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _birthdayController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      _buildFigmaTextField(
                        label: 'Correo',
                        hint: 'usuario@correo.unimet.edu.ve',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
                          final email = value.trim().toLowerCase();
                          if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) return 'Correo no válido';
                          if (!email.endsWith('@correo.unimet.edu.ve')) return 'Solo se permiten correos @correo.unimet.edu.ve';
                          return null;
                        },
                      ),
                      _buildFigmaTextField(
                        label: 'Contraseña',
                        hint: 'Al menos 8 caracteres',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa una contraseña';
                          if (value.length < 8) return 'La contraseña debe tener al menos 8 caracteres';
                          return null;
                        },
                      ),
                      _buildFigmaTextField(
                        label: 'Confirmar Contraseña',
                        hint: 'Repite tu contraseña',
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        suffix: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Confirma tu contraseña';
                          if (value != _passwordController.text) return 'Las contraseñas no coinciden';
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
                                icon: const Icon(Icons.g_mobiledata, size: 26, color: Color.fromARGB(255, 82, 192, 255)),
                                label: const Text(
                                  'Google',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: kFigmaTextDark, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: kFigmaInputBg,
                                  side: const BorderSide(color: kFigmaInputBorder),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await _signUp();
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
                              backgroundColor: kFigmaBtnPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(color: kFigmaTextDark, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: '¿Ya tienes una cuenta en Aloja? ',
                              style: TextStyle(color: Colors.black54, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Iniciar Sesión',
                                  style: TextStyle(color: kFigmaTextDark, fontWeight: FontWeight.bold),
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

  Widget _buildFigmaTextField({
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kFigmaTextDark),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFigmaBg,
      // ── BARRA SUPERIOR AMPLIADA (LOGIN) ──
      appBar: AppBar(
        toolbarHeight: 65, // Altura ampliada
        backgroundColor: kFigmaAppBarBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 24,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E1D3), width: 1.5), // Línea de segmentación
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Inicio',
                style: TextStyle(color: kFigmaTextDark, fontSize: 13, fontWeight: FontWeight.w600),
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
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kFigmaTextDark),
                ),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFigmaTextField(
                        label: 'Correo electrónico',
                        hint: 'usuario@correo.unimet.edu.ve',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
                          final email = value.trim().toLowerCase();
                          if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) return 'Correo no válido';
                          if (!email.endsWith('@correo.unimet.edu.ve')) return 'Solo se permiten correos @correo.unimet.edu.ve';
                          return null;
                        },
                      ),
                      _buildFigmaTextField(
                        label: 'Contraseña',
                        hint: 'Tu contraseña',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
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
                                icon: const Icon(Icons.g_mobiledata, size: 26, color: Color.fromARGB(255, 1, 151, 197)),
                                label: const Text(
                                  'Google',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: kFigmaTextDark, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: kFigmaInputBg,
                                  side: const BorderSide(color: kFigmaInputBorder),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
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
                              backgroundColor: kFigmaBtnPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(color: kFigmaTextDark, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: '¿No tienes una cuenta en Aloja? ',
                              style: TextStyle(color: Colors.black54, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Regístrate',
                                  style: TextStyle(color: kFigmaTextDark, fontWeight: FontWeight.bold),
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

// ── CLASE PRINCIPAL DEL LOGIN REQUERIDA ABAJO ──
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}