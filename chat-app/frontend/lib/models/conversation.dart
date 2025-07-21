import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'message.dart';

part 'conversation.g.dart';

enum ConversationType {
  @JsonValue('private')
  private,
  @JsonValue('group')
  group,
}

@JsonSerializable()
class Conversation {
  final int id;
  final String? name;
  final ConversationType type;
  @JsonKey(name: 'created_by')
  final int createdBy;
  final String? description;
  final String? avatar;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // العلاقات
  final List<User>? participants;
  @JsonKey(name: 'last_message')
  final Message? lastMessage;
  final User? creator;

  const Conversation({
    required this.id,
    this.name,
    this.type = ConversationType.private,
    required this.createdBy,
    this.description,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.participants,
    this.lastMessage,
    this.creator,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  Conversation copyWith({
    int? id,
    String? name,
    ConversationType? type,
    int? createdBy,
    String? description,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<User>? participants,
    Message? lastMessage,
    User? creator,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      creator: creator ?? this.creator,
    );
  }

  bool get isPrivate => type == ConversationType.private;
  bool get isGroup => type == ConversationType.group;

  // الحصول على اسم المحادثة المناسب
  String getDisplayName(int currentUserId) {
    if (isGroup) {
      return name ?? 'مجموعة';
    } else {
      // للمحادثات الخاصة، عرض اسم المشارك الآخر
      final otherParticipant = participants
          ?.where((user) => user.id != currentUserId)
          .firstOrNull;
      return otherParticipant?.name ?? 'مستخدم';
    }
  }

  // الحصول على صورة المحادثة المناسبة
  String? getDisplayAvatar(int currentUserId) {
    if (isGroup) {
      return avatar;
    } else {
      // للمحادثات الخاصة، عرض صورة المشارك الآخر
      final otherParticipant = participants
          ?.where((user) => user.id != currentUserId)
          .firstOrNull;
      return otherParticipant?.avatar;
    }
  }

  // التحقق من حالة المشارك الآخر (للمحادثات الخاصة)
  bool getOtherParticipantOnlineStatus(int currentUserId) {
    if (isGroup) return false;
    
    final otherParticipant = participants
        ?.where((user) => user.id != currentUserId)
        .firstOrNull;
    return otherParticipant?.isOnline ?? false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}