import '../../domain/entities/conversation_permissions.dart';

class ConversationPermissionsModel extends ConversationPermissions {
  const ConversationPermissionsModel({
    required super.canSend,
    required super.canUpload,
    required super.canCall,
    required super.canReport,
    required super.canBlock,
    required super.canReview,
    required super.isReadOnly,
    required super.canArchive,
    required super.canDelete,
  });

  factory ConversationPermissionsModel.fromJson(Map<String, dynamic> json) {
    return ConversationPermissionsModel(
      canSend: json['canSend'] as bool? ?? false,
      canUpload: json['canUpload'] as bool? ?? false,
      canCall: json['canCall'] as bool? ?? false,
      canReport: json['canReport'] as bool? ?? false,
      canBlock: json['canBlock'] as bool? ?? false,
      canReview: json['canReview'] as bool? ?? false,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
      canArchive: json['canArchive'] as bool? ?? false,
      canDelete: json['canDelete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'canSend': canSend,
        'canUpload': canUpload,
        'canCall': canCall,
        'canReport': canReport,
        'canBlock': canBlock,
        'canReview': canReview,
        'isReadOnly': isReadOnly,
        'canArchive': canArchive,
        'canDelete': canDelete,
      };
}
