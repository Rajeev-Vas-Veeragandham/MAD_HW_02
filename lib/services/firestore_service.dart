import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> getMessages(String roomId) {
    try {
      print('🔄 Getting messages for room: $roomId');
      return _db
          .collection("rooms")
          .doc(roomId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .snapshots();
    } catch (e) {
      print('❌ Error getting messages: $e');
      rethrow;
    }
  }

  static Future<bool> sendMessage(
    String roomId,
    String text,
    String userName,
  ) async {
    try {
      if (text.trim().isEmpty) {
        print('❌ Message is empty');
        return false;
      }

      print('🔄 Sending message to room: $roomId');
      
      await _db
          .collection("rooms")
          .doc(roomId)
          .collection("messages")
          .add({
            "text": text.trim(),
            "sender": userName,
            "timestamp": FieldValue.serverTimestamp(),
            "time": "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
          });

      print('✅ Message sent successfully');
      return true;
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }

  // Initialize rooms if they don't exist
  static Future<void> initializeRooms() async {
    try {
      print('🔄 Initializing rooms...');
      final rooms = [
        {'id': 'games', 'name': 'Games'},
        {'id': 'business', 'name': 'Business'},
        {'id': 'public_health', 'name': 'Public Health'},
        {'id': 'study', 'name': 'Study'},
      ];
      
      for (final room in rooms) {
        final docRef = _db.collection("rooms").doc(room['id']);
        final doc = await docRef.get();
        
        if (!doc.exists) {
          await docRef.set({
            'name': room['name'],
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('✅ Created room: ${room['name']}');
        } else {
          print('✅ Room already exists: ${room['name']}');
        }
      }
      print('✅ All rooms initialized');
    } catch (e) {
      print('❌ Error initializing rooms: $e');
      rethrow;
    }
  }
}