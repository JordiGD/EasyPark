import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/driver_provider.dart';
import '../services/driver_service.dart';
import '../widgets/custom_text_field.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final int? userId;

  const EditUserScreen({
    Key? key,
    this.userData,
    this.userId,
  }) : super(key: key);

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordMode = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (widget.userData != null) {
      _nameController.text = widget.userData?['name'] ?? '';
      _emailController.text = widget.userData?['email'] ?? '';
      _phoneController.text = widget.userData?['phoneNumber'] ??
          widget.userData?['phone_number'] ??
          '';
      _passwordController.text = '';
      _passwordConfirmController.text = '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final userData = <String, dynamic>{
        'name': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        if (_passwordController.text.isNotEmpty)
          'password': _passwordController.text,
      };

      // Si hay userId, agregarlo con el nombre correcto (userID en camelCase)
      if (widget.userId != null) {
        userData['userID'] = widget.userId!;
      } else if (widget.userData?['userID'] != null) {
        userData['userID'] = widget.userData!['userID'];
      } else if (widget.userData?['user_id'] != null) {
        userData['userID'] = widget.userData!['user_id'];
      } else {
        // Fallback: obtener del Provider si no está en userData
        final provider = context.read<DriverProvider>();
        final currentUserID =
            provider.currentUser?['userID'] ?? provider.currentUser?['user_id'];
        if (currentUserID != null) {
          userData['userID'] = currentUserID;
        }
      }

      // Preservar el rol existente para que no se envíe como null
      if (widget.userData?['role'] != null) {
        userData['role'] = widget.userData!['role'];
      } else {
        final provider = context.read<DriverProvider>();
        final currentRole = provider.currentUser?['role'];
        if (currentRole != null) {
          userData['role'] = currentRole;
        }
      }

      final service = DriverService();
      await service.updateUser(userData);

      if (mounted) {
        setState(() {
          _successMessage = '✓ Información actualizada exitosamente';
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(userData);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Información de Usuario'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Avatar
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[100],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Information Section
              _buildSectionTitle('Información Personal'),
              const SizedBox(height: 16),

              // Name
              CustomTextField(
                controller: _nameController,
                label: 'Nombre Completo',
                hint: 'Juan Pérez',
                icon: Icons.person,
                enabled: !_isLoading,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El nombre es requerido';
                  }
                  if (value!.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact Section
              _buildSectionTitle('Información de Contacto'),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                controller: _emailController,
                label: 'Correo Electrónico',
                hint: 'correo@example.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El email es requerido';
                  }
                  if (!value!.contains('@') || !value.contains('.')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              CustomTextField(
                controller: _phoneController,
                label: 'Número de Teléfono',
                hint: '+57 3101234567',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El teléfono es requerido';
                  }
                  if (value!.length < 7) {
                    return 'El teléfono debe tener al menos 7 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Security Section
              _buildSectionTitle('Seguridad'),
              const SizedBox(height: 16),

              // Password Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '¿Cambiar contraseña?',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Switch(
                      value: _isPasswordMode,
                      onChanged: !_isLoading
                          ? (value) => setState(() => _isPasswordMode = value)
                          : null,
                      activeColor: Colors.blue[700],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Password Fields (shown only if _isPasswordMode is true)
              if (_isPasswordMode) ...[
                CustomTextField(
                  controller: _passwordController,
                  label: 'Nueva Contraseña',
                  hint: '••••••••',
                  icon: Icons.lock,
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (_isPasswordMode && (value?.isEmpty ?? true)) {
                      return 'La contraseña es requerida';
                    }
                    if (_isPasswordMode && (value?.length ?? 0) < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordConfirmController,
                  label: 'Confirmar Contraseña',
                  hint: '••••••••',
                  icon: Icons.lock,
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (_isPasswordMode && (value?.isEmpty ?? true)) {
                      return 'La confirmación de contraseña es requerida';
                    }
                    if (_isPasswordMode && value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style:
                              TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Success Message
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _successMessage!,
                        style:
                            TextStyle(color: Colors.green[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage != null || _successMessage != null)
                const SizedBox(height: 16),

              // Action Buttons
              ElevatedButton(
                onPressed: _isLoading ? null : _updateUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 2,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
