import 'package:equatable/equatable.dart';

class ConversationPermissions extends Equatable {
  const ConversationPermissions({
    required this.canSend,
    required this.canUpload,
    required this.canCall,
    required this.canReport,
    required this.canBlock,
    required this.canReview,
    required this.isReadOnly,
    required this.canArchive,
    required this.canDelete,
  });

  final bool canSend;
  final bool canUpload;
  final bool canCall;
  final bool canReport;
  final bool canBlock;
  final bool canReview;
  final bool isReadOnly;
  final bool canArchive;
  final bool canDelete;

  @override
  List<Object?> get props => [
        canSend,
        canUpload,
        canCall,
        canReport,
        canBlock,
        canReview,
        isReadOnly,
        canArchive,
        canDelete,
      ];
}
