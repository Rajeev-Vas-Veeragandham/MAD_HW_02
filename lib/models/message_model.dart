class MessageModel {
  final String text;
  final String sender;
  final DateTime timestamp;
  final String time; // formatted: "12:30"

  MessageModel({
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.time,
  });

  // Firestore → MessageModel
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      text: map['text'],
      sender: map['sender'],
      timestamp: (map['timestamp']).toDate(),
      time: map['time'],
    );
  }

  // MessageModel → Firestore
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': timestamp,
      'time': time,
    };
  }
}
