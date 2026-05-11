import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  
  // Barber specific controllers
  final _shopNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _shopNumberController = TextEditingController();
  final _businessLicenseController = TextEditingController();

  bool _isLoading = false;
  bool _isBarber = false;

  void _handleRegister() async {
    // Basic validation
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _mobileController.text.isEmpty) {
      _showError('Please fill in all basic fields');
      return;
    }

    // Barber specific validation
    if (_isBarber) {
      if (_shopNameController.text.isEmpty || 
          _cityController.text.isEmpty || 
          _addressController.text.isEmpty || 
          _shopNumberController.text.isEmpty || 
          _businessLicenseController.text.isEmpty) {
        _showError('Please fill in all barber-specific fields');
        return;
      }
    }

    setState(() => _isLoading = true);
    
    final success = await Provider.of<AuthProvider>(context, listen: false).register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _mobileController.text,
      isBarber: _isBarber,
      shopName: _isBarber ? _shopNameController.text : null,
      city: _isBarber ? _cityController.text : null,
      address: _isBarber ? _addressController.text : null,
      shopNumber: _isBarber ? _shopNumberController.text : null,
      businessLicense: _isBarber ? _businessLicenseController.text : null,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      _showError('Registration failed. Check your data or try a different email.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, leading: const BackButton(color: AppTheme.textColor)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'Join our community of style seekers',
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Customer'),
                    selected: !_isBarber,
                    onSelected: (val) => setState(() => _isBarber = false),
                    selectedColor: AppTheme.accentColor,
                    labelStyle: TextStyle(color: !_isBarber ? Colors.white : AppTheme.textColor),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Barber'),
                    selected: _isBarber,
                    onSelected: (val) => setState(() => _isBarber = true),
                    selectedColor: AppTheme.accentColor,
                    labelStyle: TextStyle(color: _isBarber ? Colors.white : AppTheme.textColor),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'Full Name', LucideIcons.user),
              const SizedBox(height: 20),
              _buildTextField(_emailController, 'Email', LucideIcons.mail, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildTextField(_mobileController, 'Mobile Number', LucideIcons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', LucideIcons.lock, obscureText: true),
              
              if (_isBarber) ...[
                const SizedBox(height: 32),
                const Text('Barber Shop Details', style: TextStyle(color: AppTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildTextField(_shopNameController, 'Shop Name', LucideIcons.scissors),
                const SizedBox(height: 20),
                _buildTextField(_cityController, 'City', LucideIcons.map),
                const SizedBox(height: 20),
                _buildTextField(_addressController, 'Address', LucideIcons.mapPin),
                const SizedBox(height: 20),
                _buildTextField(_shopNumberController, 'Shop Number', LucideIcons.hash),
                const SizedBox(height: 20),
                _buildTextField(_businessLicenseController, 'Business License ID', LucideIcons.fileText),
              ],
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppTheme.textColor),
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}
