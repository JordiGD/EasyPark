import 'package:flutter/material.dart';
import '../services/driver_service.dart';
import '../widgets/custom_text_field.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const UserProfileScreen({Key? key, this.initialData}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _firstNameController.text = widget.initialData?['firstName'] ?? '';
      _lastNameController.text = widget.initialData?['lastName'] ?? '';
      _emailController.text = widget.initialData?['email'] ?? '';
      _phoneController.text = widget.initialData?['phone'] ?? '';
      _licenseController.text = widget.initialData?['license'] ?? '';
      _experienceController.text =
          widget.initialData?['experience']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final userData = {
        if (widget.initialData?['id'] != null) 'id': widget.initialData!['id'],
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'license': _licenseController.text,
        'experience': int.parse(_experienceController.text),
      };

      final service = DriverService();
      await service.updateUser(userData);

      if (mounted) {
        setState(() {
          _successMessage = '✓ Perfil actualizado exitosamente';
          _isEditMode = false;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _successMessage = null);
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
        title: const Text('Mi Perfil'),
        elevation: 0,
        actions: [
          if (!_isEditMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _isEditMode = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
              ),
            ),
        ],
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
                  child: Icon(Icons.person, size: 60, color: Colors.blue[700]),
                ),
              ),
              const SizedBox(height: 32),

              // Info Section
              _buildSectionTitle('Información Personal'),
              const SizedBox(height: 16),

              // First Name
              CustomTextField(
                controller: _firstNameController,
                label: 'Nombre',
                hint: 'Juan',
                icon: Icons.person,
                enabled: _isEditMode || widget.initialData == null,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Last Name
              CustomTextField(
                controller: _lastNameController,
                label: 'Apellido',
                hint: 'Pérez',
                icon: Icons.person,
                enabled: _isEditMode || widget.initialData == null,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El apellido es requerido';
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
                label: 'Email',
                hint: 'correo@example.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                enabled: _isEditMode || widget.initialData == null,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El email es requerido';
                  }
                  if (!value!.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              CustomTextField(
                controller: _phoneController,
                label: 'Teléfono',
                hint: '+57 3101234567',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                enabled: _isEditMode || widget.initialData == null,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El teléfono es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // License Section
              _buildSectionTitle('Información de Conducción'),
              const SizedBox(height: 16),

              // License Number
              CustomTextField(
                controller: _licenseController,
                label: 'Licencia de Conducción',
                hint: '123456789',
                icon: Icons.card_membership,
                enabled: _isEditMode || widget.initialData == null,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'La licencia es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Experience
              CustomTextField(
                controller: _experienceController,
                label: 'Años de Experiencia',
                hint: '5',
                icon: Icons.trending_up,
                keyboardType: TextInputType.number,
                enabled: _isEditMode || widget.initialData == null,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Los años de experiencia son requeridos';
                  }
                  final years = int.tryParse(value ?? '');
                  if (years == null || years < 0 || years > 80) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
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
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // Action Buttons
              if (_isEditMode) ...[
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
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
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _isEditMode = false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
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
