import 'dart:convert'; // Para convertir la imagen a texto (Base64)
import 'dart:typed_data'; // Para manejar los bytes de la imagen en Web
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Selector de imágenes
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, String> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, String> _currentUserData;
  
  // Controladores para el formulario de edición
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;
  String _selectedGender = 'Otro';

  // Variable para almacenar los bytes de la foto de perfil
  Uint8List? _profileImageBytes;

  // Variable de estado para alternar entre el Menú y el Formulario de Edición
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentUserData = Map<String, String>.from(widget.userData);
    
    _nameController = TextEditingController(text: _currentUserData['name'] ?? '');
    _emailController = TextEditingController(text: _currentUserData['email'] ?? '');
    _phoneController = TextEditingController(text: _currentUserData['phone'] ?? '');
    _birthdayController = TextEditingController(text: _currentUserData['birthday'] ?? '01/01/1995');
    _selectedGender = _currentUserData['gender'] ?? 'Otro';

    // Si ya existe una foto guardada, la decodificamos
    if (_currentUserData['profileImage'] != null && _currentUserData['profileImage']!.isNotEmpty) {
      _profileImageBytes = base64Decode(_currentUserData['profileImage']!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  // Función para abrir el selector de archivos
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    
    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _profileImageBytes = imageBytes;
        _currentUserData['profileImage'] = base64Encode(imageBytes);
      });
    }
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(35),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: const Color(0xFFE2E6D7), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF5A5A5A)),
              const SizedBox(width: 20),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF5A5A5A))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2), 
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: const Color(0xFFE9EFE6), 
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network('https://i.postimg.cc/Zn66zqnm/Logo-aloja-en-png-sin-fondo.png', height: 55, fit: BoxFit.contain),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_currentUserData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1B4332),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('Inicio', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 320, child: _buildUserCard()),
                      const SizedBox(width: 50),
                      Expanded(child: _isEditing ? _buildEditForm() : _buildMenuOptions()),
                    ],
                  )
                : Column(
                    children: [
                      _buildUserCard(),
                      const SizedBox(height: 40),
                      _isEditing ? _buildEditForm() : _buildMenuOptions(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Widget del panel lateral del usuario (Aquí unificamos el botón de la cámara)
  Widget _buildUserCard() {
    String name = _currentUserData['name'] ?? 'Usuario';
    String email = _currentUserData['email'] ?? 'correo@unimet.edu.ve';
    String phone = _currentUserData['phone'] ?? '+58 --- -------';
    String birthday = _currentUserData['birthday'] ?? 'dd/mm/aaaa';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stack dinámico: si está editando, añade el botón flotante de la cámara en la tarjeta izquierda
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5E5),
                  shape: BoxShape.circle,
                ),
                child: _profileImageBytes != null
                    ? ClipOval(child: Image.memory(_profileImageBytes!, fit: BoxFit.cover))
                    : const Icon(Icons.person, size: 70, color: Color(0xFF656565)),
              ),
              if (_isEditing) // SOLO muestra la cámara si estamos en la pantalla de editar
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A6248),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
          const SizedBox(height: 4),
          Text(email, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 35),
          
          _buildCardInfoRow('Se unió:', birthday),
          _buildCardInfoRow('Teléfono:', phone),
          _buildCardInfoRow('Contraseña:', '*********', trailing: const Icon(Icons.visibility_off_outlined, size: 18, color: Colors.black54)),
          _buildCardInfoRow('Sitios Reservados:', '0'),
          
          const SizedBox(height: 40),
          
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop({'action': 'logout'}),
            icon: const Icon(Icons.exit_to_app, color: Color(0xFFC84B22)),
            label: const Text('Cerrar Sesión', style: TextStyle(color: Color(0xFFC84B22), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Gestiona tu cuenta', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 35),
        _buildMenuButton(
          icon: Icons.settings,
          title: 'Editar perfil de usuario',
          onTap: () {
            setState(() {
              _nameController.text = _currentUserData['name'] ?? '';
              _emailController.text = _currentUserData['email'] ?? '';
              _phoneController.text = _currentUserData['phone'] ?? '';
              _birthdayController.text = _currentUserData['birthday'] ?? '01/01/1995';
              _selectedGender = _currentUserData['gender'] ?? 'Otro';
              _isEditing = true;
            });
          },
        ),
        _buildMenuButton(icon: Icons.handyman_rounded, title: 'Administrar reservas y publicaciones', onTap: () => _showComingSoonSnackBar('Administración de reservas')),
        _buildMenuButton(icon: Icons.support_agent_rounded, title: 'Contacto con el servicio técnico al cliente', onTap: () => _showComingSoonSnackBar('Servicio Técnico')),
        _buildMenuButton(icon: Icons.engineering_rounded, title: 'Solicitar permiso para convertirse en administrador', onTap: () => _showComingSoonSnackBar('Solicitud de Administrator')),
      ],
    );
  }

  // Vista B: Formulario "Edita tu información" (Sin el círculo redundante del medio)
  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1B4332)), onPressed: () => setState(() => _isEditing = false)),
              const Text('Edita tu información', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 48, bottom: 35),
            child: Text('Actualiza tu foto de perfil, nombre y datos de contacto.', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ),
          
          _buildTextField(controller: _nameController, labelText: 'Nombre completo'),
          _buildTextField(controller: _emailController, labelText: 'Correo electrónico'),
          _buildTextField(controller: _phoneController, labelText: 'Teléfono'),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(labelText: 'Sexo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              items: <String>['Masculino', 'Femenino', 'Otro'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedGender = newValue ?? 'Otro'),
            ),
          ),
          
          _buildTextField(
            controller: _birthdayController, 
            labelText: 'Fecha de nacimiento',
            suffixIcon: Icons.calendar_today,
            onSuffixTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime(1995, 1, 1),
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _birthdayController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                });
              }
            }
          ),
          
        
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {

                try {
        // 1. Obtener el ID del usuario actual
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("No hay usuario logueado");

        // 2. Crear el mapa con los nuevos datos
        Map<String, dynamic> updatedData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'birthday': _birthdayController.text,
          'gender': _selectedGender,
          // Solo guardamos la imagen si el usuario cambió la original
          if (_profileImageBytes != null) 'profileImage': base64Encode(_profileImageBytes!),
        };

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
  'profile': updatedData, // Esto actualizará el mapa 'profile' en lugar de la raíz
});
                
                setState(() {
                  _currentUserData['name'] = _nameController.text;
                  _currentUserData['email'] = _emailController.text;
                  _currentUserData['phone'] = _phoneController.text;
                  _currentUserData['birthday'] = _birthdayController.text;
                  _currentUserData['gender'] = _selectedGender;
                  _isEditing = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cambios guardados con éxito'), backgroundColor: Color(0xFF1B4332)),
                );
              } catch (e) {
        // Feedback de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
              }
            
  },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A6248),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Guardar cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String labelText, IconData? suffixIcon, VoidCallback? onSuffixTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Color(0xFF5A5A5A)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          suffixIcon: suffixIcon != null ? IconButton(icon: Icon(suffixIcon, color: const Color(0xFF1B4332)), onPressed: onSuffixTap) : null,
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad de "$feature" estará disponible próximamente.'), backgroundColor: const Color(0xFF1B4332)),
    );
  }
}