import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Firebase Instances (Assumes they are initialized in main.dart) ---
final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

// Helper to get the current user's ID safely
String getCurrentUserId() {
  // If the user is logged in, use their UID. Fallback to a placeholder if needed.
  return auth.currentUser?.uid ?? 'anonymous_user';
}

// Global path prefix for Firestore security rules (MUST MATCH security rules)
const String appPathPrefix = 'artifacts/aniflix/public/data';

// --- Gemini API Configuration ---
// IMPORTANT: Replace the empty string with your actual Gemini API Key
// Note: In a real production app, this key should be stored securely,
// not hardcoded in the codebase.
const String geminiApiKey = "gemini_api_key";

// --- Utility function to generate a consistent chat ID between two users ---
String generateChatId(String user1Id, String user2Id) {
  // Ensures the chat ID is the same regardless of who starts the chat
  final sortedIds = [user1Id, user2Id]..sort();
  return '${sortedIds[0]}_${sortedIds[1]}';
}
