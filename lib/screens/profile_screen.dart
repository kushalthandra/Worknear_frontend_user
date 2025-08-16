import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isUploadingImage = false;
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _webImage;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      _currentUser = Supabase.instance.client.auth.currentUser;
      
      if (_currentUser != null) {
        // Load user metadata and any additional profile data
        final userMetadata = _currentUser!.userMetadata ?? {};
        
        setState(() {
          _userProfile = {
            'email': _currentUser!.email,
            'name': userMetadata['username'] ?? userMetadata['name'] ?? '',
            'phone': userMetadata['phone'] ?? '',
            'location': userMetadata['location'] ?? '',
            'bio': userMetadata['bio'] ?? '',
            'avatar_url': userMetadata['avatar_url'] ?? '',
            'created_at': _currentUser!.createdAt,
          };
          
          _currentAvatarUrl = _userProfile!['avatar_url'];
          
          // Populate controllers
          _nameController.text = _userProfile!['name'] ?? '';
          _phoneController.text = _userProfile!['phone'] ?? '';
          _locationController.text = _userProfile!['location'] ?? '';
          _bioController.text = _userProfile!['bio'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      // Show image source selection dialog
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web platform
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _imageFile = null;
          });
        } else {
          // For mobile platforms
          setState(() {
            _imageFile = File(pickedFile.path);
            _webImage = null;
          });
        }
        
        // Upload image immediately after selection
        await _uploadImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF547DCD)),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF547DCD)),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null && _webImage == null) return;
    
    setState(() => _isUploadingImage = true);
    
    try {
      final String fileName = '${_currentUser!.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      String? imageUrl;
      
      if (kIsWeb && _webImage != null) {
        // Upload for web
        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(fileName, _webImage!);
      } else if (_imageFile != null) {
        // Upload for mobile
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(fileName, _imageFile!);
      }
      
      // Get public URL
      imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);
      
      // Update user metadata with new avatar URL
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            ..._currentUser!.userMetadata ?? {},
            'avatar_url': imageUrl,
          },
        ),
      );
      
      setState(() {
        _currentAvatarUrl = imageUrl;
        _imageFile = null;
        _webImage = null;
      });
      
      await _loadUserProfile(); // Refresh profile
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'name': _nameController.text.trim(),
              'username': _nameController.text.trim(),
              'phone': _phoneController.text.trim(),
              'location': _locationController.text.trim(),
              'bio': _bioController.text.trim(),
              'avatar_url': _currentAvatarUrl ?? '',
            },
          ),
        );
        
        await _loadUserProfile(); // Refresh profile data
        
        setState(() => _isEditing = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF547DCD),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isEditing = false);
                _loadUserProfile(); // Reset form
              },
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF547DCD)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildProfileForm(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF547DCD).withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 47,
                  backgroundColor: const Color(0xFF547DCD).withOpacity(0.1),
                  child: _buildAvatarContent(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _pickImage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF547DCD),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isUploadingImage
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Name and Email
          Text(
            _userProfile?['name']?.isNotEmpty == true 
                ? _userProfile!['name'] 
                : 'No name set',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF547DCD),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile?['email'] ?? 'No email',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          // Member since
          if (_userProfile?['created_at'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Member since ${_formatDate(_userProfile!['created_at'])}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    // Show selected image (temporary)
    if (_webImage != null) {
      return ClipOval(
        child: Image.memory(
          _webImage!,
          width: 94,
          height: 94,
          fit: BoxFit.cover,
        ),
      );
    }
    
    if (_imageFile != null) {
      return ClipOval(
        child: Image.file(
          _imageFile!,
          width: 94,
          height: 94,
          fit: BoxFit.cover,
        ),
      );
    }
    
    // Show current avatar
    if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _currentAvatarUrl!,
          width: 94,
          height: 94,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF547DCD),
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.person,
            size: 50,
            color: Color(0xFF547DCD),
          ),
        ),
      );
    }
    
    // Default avatar
    return const Icon(
      Icons.person,
      size: 50,
      color: Color(0xFF547DCD),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF547DCD),
              ),
            ),
            const SizedBox(height: 20),
            
            // Name Field
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Phone Field
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty && !RegExp(r'^\d{10,}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Location Field
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on,
              enabled: _isEditing,
              validator: null,
            ),
            const SizedBox(height: 16),
            
            // Bio Field
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.info,
              enabled: _isEditing,
              maxLines: 3,
              validator: null,
            ),
            
            if (_isEditing) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                        _loadUserProfile();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF547DCD),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _updateProfile,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF547DCD)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF547DCD)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Settings Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF547DCD),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingsItem(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications settings coming soon!')),
                  );
                },
              ),
              const Divider(),
              
              _buildSettingsItem(
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy settings coming soon!')),
                  );
                },
              ),
              const Divider(),
              
              _buildSettingsItem(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help or contact support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help center coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Sign Out Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _showSignOutDialog(),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Sign Out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF547DCD).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF547DCD)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}