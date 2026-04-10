import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/driver_provider.dart';
import 'edit_user_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const UserProfileScreen({Key? key, this.initialData}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    // Obtener usuario del Provider si está disponible, sino del initialData
    final provider = context.read<DriverProvider>();
    _userData = provider.currentUser ?? widget.initialData ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditUserScreen(
                        userData: _userData,
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _userData = result;
                    });
                  }
                },
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

            // Name
            _buildInfoCard(
              icon: Icons.person,
              label: 'Nombre Completo',
              value: _userData['name'] ?? '---',
            ),
            const SizedBox(height: 12),

            // Contact Section
            _buildSectionTitle('Información de Contacto'),
            const SizedBox(height: 16),

            // Email
            _buildInfoCard(
              icon: Icons.email,
              label: 'Email',
              value: _userData['email'] ?? '---',
            ),
            const SizedBox(height: 12),

            // Phone
            _buildInfoCard(
              icon: Icons.phone,
              label: 'Teléfono',
              value: _userData['phoneNumber'] ??
                  _userData['phone_number'] ??
                  '---',
            ),
            const SizedBox(height: 24),

            // Edit Button
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditUserScreen(
                      userData: _userData,
                    ),
                  ),
                );
                if (result != null && mounted) {
                  setState(() {
                    _userData = result;
                  });
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Modificar Información'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
