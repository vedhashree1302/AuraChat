import 'package:aniflix/ChatPage.dart';
import 'package:aniflix/HomePage.dart';
import 'package:aniflix/ProfilePage.dart';
import 'package:flutter/material.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  // Theme colors
  static const Color darkIndigo = Color(0xFF16101B);
  static const Color darkPurple = Color(0xFF2F204D);
  static const Color accent = Color.fromARGB(255, 224, 176, 255);
  static const Color surface = darkPurple;
  static const Color textSecondary = Color(0xFFBDB8C7);

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allContacts = [
    {
      'name': 'Daniel Kim',
      'status': 'Online, Software Engineer',
      'avatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'name': 'Jasmine Wu',
      'status': 'Away, UX Designer',
      'avatarUrl': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Marcus Bell',
      'status': 'Busy, Product Manager',
      'avatarUrl': 'https://i.pravatar.cc/150?img=13',
    },
    {
      'name': 'Chloe Baker',
      'status': 'Online, Data Scientist',
      'avatarUrl': 'https://i.pravatar.cc/150?img=14',
    },
    {
      'name': 'Ethan Hunt',
      'status': 'Offline, Agent',
      'avatarUrl': 'https://i.pravatar.cc/150?img=15',
    },
    {
      'name': 'Olivia Adams',
      'status': 'Online, Marketing Specialist',
      'avatarUrl': 'https://i.pravatar.cc/150?img=16',
    },
  ];

  List<Map<String, String>> _filteredContacts = [];
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _filteredContacts = _allContacts;
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts.where((contact) {
          return (contact['name'] as String).toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _startChat(Map<String, String> contact) {
    final name = contact['name']!;
    final avatar = contact['avatarUrl']!;
    final id = 'user_${name.toLowerCase().replaceAll(' ', '_')}';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatName: name,
          chatPartnerId: id,
          chatPartnerAvatar: avatar,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: const Icon(Icons.home_outlined, size: 30, color: Colors.white),
      onPressed: () {
        setState(() => _currentIndex = index);
        if (index == 0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
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
        color: surface,
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
            onTap: () {}, // Already on NewChatPage
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_call, color: Colors.white, size: 28),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
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
        title: const Text(
          'New Conversation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkIndigo,
        iconTheme: const IconThemeData(color: accent),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [darkIndigo, darkPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search contacts...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: accent),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  final name = contact['name']!;
                  final status = contact['status']!;
                  final avatar = contact['avatarUrl']!;

                  return ListTile(
                    onTap: () => _startChat(contact),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(avatar),
                      backgroundColor: Colors.grey[800],
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      status,
                      style: TextStyle(color: Colors.white70.withOpacity(0.7)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white54,
                      size: 16,
                    ),
                  );
                },
              ),
            ),
            if (_searchController.text.isNotEmpty && _filteredContacts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No contacts found matching your search.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
