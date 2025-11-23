// lib/homepage.dart
import 'package:aniflix/ChatPage.dart';
import 'package:aniflix/NewChatPage.dart';
import 'package:aniflix/ProfilePage.dart';
import 'package:aniflix/StoryViewer.dart';
import 'package:flutter/material.dart';
// Ensure file names match your project (lowercase recommended)
// ✅ Correct import (matches lib/story_viewer.dart)
import 'package:aniflix/dummy_stories.dart'; // Uses Map<String, List<Map<String,dynamic>>> as you shared

// --- LOGIC CONFIGURATION ---
const String _currentLoggedInUserEmail = 'vedhashree130207@gmail.com';
const String _targetAdminEmail = 'vedhashree130207@gmail.com';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Theme Colors (dark palette) ---
  static const Color darkIndigo = Color(0xFF16101B);
  static const Color darkPurple = Color(0xFF2F204D);
  static const Color lightAccent = Color(0xFFE0B0FF);

  static const Color bg = darkIndigo;
  static const Color surface = darkPurple;
  static const Color accent = lightAccent;

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFBDB8C7);
  static const Color dividerColor = Color(0x33221A33);

  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Data Source
  late final List<Map<String, dynamic>> _chats;
  List<Map<String, dynamic>> _filteredChats = [];

  // Dummy Data with IDs required for ChatPage
  final List<Map<String, dynamic>> _adminChats = [
    {
      'id': 'u_theresa',
      'name': 'Theresa Webb',
      'message': 'Hi, how are you?',
      'time': '27 min',
      'unreadCount': 0,
      'avatarUrl': 'https://i.pravatar.cc/150?img=1',
      'isActive': true,
    },
    {
      'id': 'u_eleanor',
      'name': 'Eleanor Pena',
      'message': 'Ok, Let me Check',
      'time': '31 min',
      'unreadCount': 0,
      'avatarUrl': 'https://i.pravatar.cc/150?img=2',
      'isActive': true,
    },
    {
      'id': 'u_marvin',
      'name': 'Marvin McKinney',
      'message': 'What are you doing?',
      'time': '2:13 PM',
      'unreadCount': 2,
      'avatarUrl': 'https://i.pravatar.cc/150?img=3',
      'isActive': false,
    },
    {
      'id': 'u_arlene',
      'name': 'Arlene McCoy',
      'message': 'I\'m so excited for....',
      'time': 'Yesterday',
      'unreadCount': 0,
      'avatarUrl': 'https://i.pravatar.cc/150?img=4',
      'isActive': false,
    },
    {
      'id': 'u_bessie',
      'name': 'Bessie Cooper',
      'message': 'The new build ready for testing.',
      'time': '14 Jan',
      'unreadCount': 1,
      'avatarUrl': 'https://i.pravatar.cc/150?img=5',
      'isActive': true,
    },
  ];

  // Story Data (avatars row)
  final List<Map<String, dynamic>> _storyData = [
    {'name': 'Story', 'url': null, 'isActive': false},
    {
      'name': 'M.Lorry',
      'url': 'https://i.pravatar.cc/150?img=4L',
      'isActive': true,
    },
    {
      'name': 'Sara',
      'url':
          'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?cs=srgb&dl=pexels-pixabay-415829.jpg&fm=jpg',
      'isActive': true,
    },
    {
      'name': 'Silva',
      'url':
          'https://mrglazier.com/wp-content/uploads/2024/02/f43f3f849439beaf398e038f517bf28408da1703.png',
      'isActive': true,
    },
    {
      'name': 'Anya',
      'url':
          'https://media.istockphoto.com/id/1154642632/photo/close-up-portrait-of-brunette-woman.webp?a=1&b=1&s=612x612&w=0&k=20&c=a9F3JVJrROyXgTP4zgtxPnOiAOMrv9qRY4NF8n0hN7E=',
      'isActive': true,
    },
    {
      'name': 'John',
      'url':
          'https://tse4.mm.bing.net/th/id/OIP.TnalbNc46_Vr8TT_dq0zTwHaFj?rs=1&pid=ImgDetMain&o=7&rm=3',
      'isActive': false,
    },
    {
      'name': 'Ben',
      'url': 'https://phflower.com/wp-content/uploads/2024/07/Victor.jpg',
      'isActive': false,
    },
    {
      'name': 'MyFamilyGrp',
      'url':
          'https://images.squarespace-cdn.com/content/v1/5d7869b9b130fb20c889732f/1574880668055-6SZRF7C8Q8N9IP9E0GK9/Roberts+Family_5x7+web.jpg?format=1000w',
      'isActive': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (_currentLoggedInUserEmail == _targetAdminEmail) {
      _chats = _adminChats;
    } else {
      _chats = [];
    }
    _filteredChats = _chats;
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChats = _chats;
      } else {
        _filteredChats = _chats.where((chat) {
          return (chat['name'] as String).toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = (_chats.isEmpty && _searchController.text.isEmpty)
        ? _buildNewUserEmptyState()
        : _buildChatListScreen();

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(),
      body: content,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- MAIN CONTENT BUILDER ---
  Widget _buildChatListScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildSearchBar(),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 15.0),
          child: Text(
            'Active',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        _buildStoriesRow(),

        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 15.0, bottom: 5.0),
          child: Text(
            'Message',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: _filteredChats.length,
            itemBuilder: (context, index) {
              final chat = _filteredChats[index];
              return _ChatTile(
                name: chat['name'],
                messagePreview: chat['message'],
                time: chat['time'],
                unreadCount: chat['unreadCount'],
                avatarUrl: chat['avatarUrl'],
                chatPartnerId: chat['id'],
                isActive: chat['isActive'],
                textColor: textPrimary,
                unreadBadgeColor: accent,
                activeDotColor: accent,
                subtitleColor: textSecondary,
              );
            },
          ),
        ),
      ],
    );
  }

  // --- EMPTY STATE FOR NEW USERS ---
  Widget _buildNewUserEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 60,
                color: accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start a new conversation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome, $_currentLoggedInUserEmail!\nYou haven\'t chatted with anyone yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: textSecondary, height: 1.5),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NewChatPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Find People"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: darkIndigo,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.chevron_left, color: textPrimary, size: 30),
            Text(
              'Message',
              style: TextStyle(
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.more_horiz, color: textPrimary, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 52,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: dividerColor),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.28), // glow color
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: accent,
          decoration: InputDecoration(
            hintText: 'Search People',
            hintStyle: TextStyle(color: textSecondary),
            prefixIcon: Icon(Icons.search, color: textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesRow() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _storyData.length,
        itemBuilder: (context, index) {
          final item = _storyData[index];
          if (item['url'] == null) {
            return _buildAddStoryButton();
          }
          return _buildStoryPhoto(item['name'], item['url'], item['isActive']);
        },
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.35), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: dividerColor, width: 1),
                ),
                child: Center(child: Icon(Icons.add, color: accent, size: 30)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('Story', style: TextStyle(fontSize: 12, color: textSecondary)),
        ],
      ),
    );
  }

  // Avatar with navigation to StoryViewer
  Widget _buildStoryPhoto(String name, String url, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // With your current dummyStories structure: Map<String, List<Map<String,dynamic>>>
              final stories = dummyStories[name];
              if (stories != null && stories.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StoryViewer(
                      userName: name,
                      stories: stories,
                      avatarUrl:
                          url, // ✅ Show the same avatar at top of StoryViewer
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: surface,
                    content: Text(
                      'No stories available for $name',
                      style: TextStyle(color: textPrimary),
                    ),
                  ),
                );
              }
            },
            child: Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipOval(
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                  ),
                ),
                if (isActive)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewChatPage()),
            ),
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
              child: Icon(Icons.add_call, color: bg, size: 28),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: textSecondary,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = _currentIndex == index;
    return IconButton(
      icon: Icon(icon, size: 30, color: isActive ? accent : textSecondary),
      onPressed: () => setState(() => _currentIndex = index),
    );
  }
}

// --- Chat tile ---
class _ChatTile extends StatelessWidget {
  final String name;
  final String messagePreview;
  final String time;
  final int unreadCount;
  final String avatarUrl;
  final String chatPartnerId;
  final bool isActive;
  final Color textColor;
  final Color unreadBadgeColor;
  final Color activeDotColor;
  final Color subtitleColor;

  const _ChatTile({
    required this.name,
    required this.messagePreview,
    required this.time,
    required this.unreadCount,
    required this.avatarUrl,
    required this.chatPartnerId,
    required this.isActive,
    required this.textColor,
    required this.unreadBadgeColor,
    required this.activeDotColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatName: name,
              chatPartnerId: chatPartnerId,
              chatPartnerAvatar: avatarUrl,
            ),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: const Color(0xFF1F1A27),
          ),
          if (isActive)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: activeDotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF16101B), width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          messagePreview,
          style: TextStyle(color: subtitleColor, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: TextStyle(
              color: unreadCount > 0 ? unreadBadgeColor : subtitleColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          if (unreadCount > 0)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: unreadBadgeColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
