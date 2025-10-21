class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final DateTime sentDate;
  final Map<String, dynamic> data;
  final String? imageUlrl;

  PushMessage(
      {required this.messageId,
      required this.title,
      required this.body,
      required this.sentDate,
      required this.data,
      required this.imageUlrl});

  @override
  String toString() {
    return '''
    messageId: $messageId,
    title: $title,
    body: $body,
    sentDate: $sentDate,
    data: $data,
    imageUlrl: $imageUlrl
  ''';
  }
}
