import 'package:aniflix/LoginPage.dart';
import 'package:aniflix/HomePage.dart';
import 'package:aniflix/NewChatPage.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  static const Color darkIndigo = Color(0xFF16101B);
  static const Color darkPurple = Color(0xFF2F204D);
  static const Color lightAccent = Color.fromARGB(255, 223, 174, 255);
  static const Color textSecondary = Color(0xFFBDB8C7);

  late AnimationController _pulseController;
  late Animation<double> _pulse;

  String name = "Sakura";
  String email = "head@teamofhead.com";
  String description = "UX Designer • Dreamer • Builder";

  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulse = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _editProfile() {
    final nameController = TextEditingController(text: name);
    final descController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkIndigo,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                name = nameController.text;
                description = descController.text;
              });
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 229, 174, 255),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color.fromARGB(255, 229, 174, 255)),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white54,
        size: 16,
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = _currentIndex == index;
    return IconButton(
      icon: Icon(icon, size: 30, color: isActive ? lightAccent : Colors.white),
      onPressed: () {
        setState(() => _currentIndex = index);
        if (index == 0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (index == 1) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const NewChatPage()));
        } else if (index == 2) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
        }
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: darkPurple,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 0),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewChatPage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 231, 174, 255),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      231,
                      174,
                      255,
                    ).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_call,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 28,
              ), // ✅ white icon
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color.fromARGB(255, 252, 176, 255), // ✅ white icon
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkIndigo,
      appBar: AppBar(
        backgroundColor: darkIndigo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Color.fromARGB(255, 194, 152, 225)),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Column(
        children: [
          const SizedBox(height: 30),
          ScaleTransition(
            scale: _pulse,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      159,
                      74,
                      172,
                    ).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://i.pinimg.com/originals/99/8f/41/998f41fc4c63e69c06b99a6e03629815.jpg',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _editProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: lightAccent,
              foregroundColor: darkIndigo,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: darkPurple,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildMenuItem(Icons.lock, 'Privacy', () {}),
                  _buildMenuItem(Icons.shopping_cart, 'Purchase', () {}),
                  _buildMenuItem(Icons.help_outline, 'Help & Support', () {}),
                  _buildMenuItem(Icons.settings, 'Settings', () {}),
                  _buildMenuItem(Icons.group_add, 'Invite a Friend', () {}),
                  _buildMenuItem(Icons.logout, 'Logout', _logout),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
