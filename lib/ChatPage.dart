// lib/ChatPage.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// Gemini client package
import 'package:google_generative_ai/google_generative_ai.dart';
import 'secret.dart';

import 'dummy_conversations.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseStorage storage = FirebaseStorage.instance;

String get currentUserId => auth.currentUser?.uid ?? "TEMP_USER";

String generateChatId(String u1, String u2) {
  final ids = [u1, u2]..sort();
  return "${ids[0]}_${ids[1]}";
}

class ChatPage extends StatefulWidget {
  final String chatName;
  final String chatPartnerId;
  final String chatPartnerAvatar;

  const ChatPage({
    super.key,
    required this.chatName,
    required this.chatPartnerId,
    required this.chatPartnerAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const Color primaryPurple = Color(0xFF9370DB);
  static const Color chatBackgroundColor = Color(0xFF1A1520);
  static const Color myBubbleColor = Color(0xFF6C4DC2);
  static const Color partnerBubbleColor = Color(0xFF3B2F45);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  late String _chatId;
  late CollectionReference _messagesRef;

  List<Map<String, dynamic>> localDummyMessages = [];

  bool _sendingImage = false;
  bool _isAITyping = false;

  @override
  void initState() {
    super.initState();

    _chatId = generateChatId(currentUserId, widget.chatPartnerId);

    _messagesRef = db
        .collection('artifacts')
        .doc('aniflix')
        .collection('public')
        .doc('data')
        .collection('chats')
        .doc(_chatId)
        .collection('messages');

    if (dummyChats.containsKey(widget.chatName)) {
      localDummyMessages = dummyChats[widget.chatName]!.map((m) {
        return {
          'text': m['text'] ?? '',
          'isMe': m['isMe'] ?? false,
          'time': m['time'] ?? '',
          'imageUrl': m['imageUrl'],
        };
      }).toList();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? text, String? imageUrl}) async {
    final payloadText = (text ?? '').trim();
    if (payloadText.isEmpty && imageUrl == null) return;

    if (text != null && text.isNotEmpty) _messageController.clear();

    try {
      await _messagesRef.add({
        "text": payloadText,
        "imageUrl": imageUrl,
        "senderId": currentUserId,
        "receiverId": widget.chatPartnerId,
        "timestamp": FieldValue.serverTimestamp(),
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });

      if (text != null && text.trim().isNotEmpty) {
        setState(() => _isAITyping = true);

        Future.delayed(const Duration(seconds: 1), () {
          _sendAIReply(text);
        });
      }
    } catch (e) {
      debugPrint("Send message error: $e");
    }
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1500,
        maxHeight: 1500,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _sendingImage = true);

      final file = File(picked.path);

      // --- Firebase Storage Path ---
      final filename =
          "IMG_${DateTime.now().millisecondsSinceEpoch}_${currentUserId}.jpg";
      final ref = storage.ref().child("messages/$_chatId/$filename");

      // --- Upload File ---
      final UploadTask uploadTask = ref.putFile(file);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // --- Save message to Firestore ---
      await _messagesRef.add({
        "text": "",
        "imageUrl": downloadUrl,
        "senderId": currentUserId,
        "receiverId": widget.chatPartnerId,
        "timestamp": FieldValue.serverTimestamp(),
      });

      // Auto scroll after send
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint("🔥 ERROR uploading image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to upload image")));
      }
    } finally {
      if (mounted) setState(() => _sendingImage = false);
    }
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return "";
    final d = ts.toDate();
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildMessageBubble({
    required bool isMe,
    required String? text,
    required String? imageUrl,
    required Timestamp? timestamp,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: InteractiveViewer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(imageUrl),
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, w, p) {
                      if (p == null) return w;
                      return SizedBox(
                        width: 150,
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: p.expectedTotalBytes != null
                                ? p.cumulativeBytesLoaded /
                                      (p.expectedTotalBytes ?? 1)
                                : null,
                            color: Colors.white54,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            if (text != null && text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe ? myBubbleColor : partnerBubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isMe
                        ? const Radius.circular(18)
                        : const Radius.circular(5),
                    bottomRight: isMe
                        ? const Radius.circular(5)
                        : const Radius.circular(18),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTime(timestamp),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: _messagesRef.orderBy("timestamp").snapshots(),
      builder: (context, snapshot) {
        List<Widget> bubbles = [];

        for (var dm in localDummyMessages) {
          bubbles.add(
            _buildMessageBubble(
              isMe: dm['isMe'],
              text: dm['text'],
              imageUrl: dm['imageUrl'],
              timestamp: null,
            ),
          );
        }

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            bubbles.add(
              _buildMessageBubble(
                isMe: data['senderId'] == currentUserId,
                text: data['text'],
                imageUrl: data['imageUrl'],
                timestamp: data['timestamp'],
              ),
            );
          }
        }

        if (_isAITyping) {
          bubbles.add(
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: partnerBubbleColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white54,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "typing...",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 20),
          children: bubbles,
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      color: chatBackgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: () async {
              final choice = await showModalBottomSheet<ImageSource>(
                context: context,
                builder: (c) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text("Gallery"),
                        onTap: () => Navigator.pop(c, ImageSource.gallery),
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text("Camera"),
                        onTap: () => Navigator.pop(c, ImageSource.camera),
                      ),
                    ],
                  ),
                ),
              );

              if (choice != null) {
                await _pickAndSendImage(choice);
              }
            },
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: partnerBubbleColor,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Type here...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                onSubmitted: (_) => _sendMessage(text: _messageController.text),
              ),
            ),
          ),

          const SizedBox(width: 10),

          _sendingImage
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : GestureDetector(
                  onTap: () => _sendMessage(text: _messageController.text),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: primaryPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ---------------------------
  // WORKING GEMINI AI REPLY FIX
  // ---------------------------
  Future<void> _sendAIReply(String userMessage) async {
    try {
      final model = GenerativeModel(
        model: "gemini-1.5-flash",
        apiKey: GEMINI_API_KEY,
      );

      final prompt =
          """
Reply casually in 1–2 short sentences.
Your goal is to sound like a friendly texting buddy.

User: "$userMessage"
""";

      final response = await model.generateContent([Content.text(prompt)]);

      // -------- SAFE EXTRACTION (No errors) --------
      String aiText = "";

      try {
        final candidate = response.candidates.first;
        final content = candidate?.content;
        final parts = content?.parts;

        if (parts != null && parts.isNotEmpty) {
          final part = parts.first;

          if (part is TextPart) {
            aiText = part.text.trim() ?? "";
          }
        }
      } catch (_) {
        aiText = "";
      }

      if (aiText.isEmpty) aiText = "Okay!";

      // -------- Save bot reply to Firestore --------
      await _messagesRef.add({
        "text": aiText,
        "imageUrl": null,
        "senderId": widget.chatPartnerId,
        "receiverId": currentUserId,
        "timestamp": FieldValue.serverTimestamp(),
      });

      // Auto scroll
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint("AI error: $e");
    } finally {
      if (mounted) setState(() => _isAITyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: chatBackgroundColor,
      appBar: AppBar(
        backgroundColor: chatBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatPartnerAvatar),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Active now",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildChatMessages()),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
