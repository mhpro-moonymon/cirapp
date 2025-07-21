import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'message.g.dart';

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
  @JsonValue('voice')
  voice,
}

@JsonSerializable()
class Message {
  final int id;
  @JsonKey(name: 'conversation_id')
  final int conversationId;
  @JsonKey(name: 'sender_id')
  final int senderId;
  final String? content;
  final MessageType type;
  @JsonKey(name: 'file_path')
  final String? filePath;
  @JsonKey(name: 'file_name')
  final String? fileName;
  @JsonKey(name: 'file_size')
  final int? fileSize;
  @JsonKey(name: 'is_edited')
  final bool isEdited;
  @JsonKey(name: 'reply_to')
  final int? replyTo;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  // العلاقات
  final User? sender;
  @JsonKey(name: 'reply_to_message')
  final Message? replyToMessage;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.type = MessageType.text,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.isEdited = false,
    this.replyTo,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.replyToMessage,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? content,
    MessageType? type,
    String? filePath,
    String? fileName,
    int? fileSize,
    bool? isEdited,
    int? replyTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? sender,
    Message? replyToMessage,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      isEdited: isEdited ?? this.isEdited,
      replyTo: replyTo ?? this.replyTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      replyToMessage: replyToMessage ?? this.replyToMessage,
    );
  }

  bool get isTextMessage => type == MessageType.text;
  bool get isImageMessage => type == MessageType.image;
  bool get isFileMessage => type == MessageType.file;
  bool get isVoiceMessage => type == MessageType.voice;
  bool get hasReply => replyTo != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}