import 'package:flutter/material.dart';
import 'package:pezshkyar/config/constants.dart';
import 'package:pezshkyar/models/message_model.dart';
import 'package:google_fonts/google_fonts.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatBubble extends StatefulWidget {
  final Message message;
  final bool showDate;
  final double maxWidth;
  final MessageStatus status;
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Function(String)? onReaction;
  final List<String>? reactions;
  final bool showReactions;
  final bool showActions;

  const ChatBubble({
    Key? key,
    required this.message,
    this.showDate = false,
    this.maxWidth = 300,
    this.status = MessageStatus.sent,
    this.onLongPress,
    this.onReply,
    this.onForward,
    this.onDelete,
    this.onEdit,
    this.onReaction,
    this.reactions,
    this.showReactions = false,
    this.showActions = false,
  }) : super(key: key);

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  bool _showActions = false;
  bool _showReactionsPanel = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showDate)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.message.formattedDate,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) _buildAvatar(isUser: false),
              Flexible(
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _showActions = !_showActions;
                      _animationController.reset();
                      _animationController.forward();
                    });
                    if (widget.onLongPress != null) {
                      widget.onLongPress!();
                    }
                  },
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: widget.maxWidth),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? LinearGradient(
                                colors: [
                                  AppConstants.primaryColor,
                                  AppConstants.secondaryColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isUser
                            ? null
                            : (isDarkMode
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.white.withOpacity(0.9)),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Message content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            child: Text(
                              widget.message.text,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: isUser
                                    ? Colors.white
                                    : (isDarkMode
                                          ? Colors.white
                                          : Colors.black87),
                              ),
                              softWrap: true,
                            ),
                          ),

                          // Reactions
                          if (widget.reactions != null &&
                              widget.reactions!.isNotEmpty)
                            _buildReactions(),

                          // Timestamp and status
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.message.formattedTime,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isUser
                                        ? Colors.white70
                                        : (isDarkMode
                                              ? Colors.white54
                                              : Colors.black38),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                _buildStatusIcon(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isUser) _buildAvatar(isUser: true),
            ],
          ),

          // Reactions panel
          if (_showReactionsPanel) _buildReactionsPanel(),

          // Actions panel
          if (_showActions || widget.showActions) _buildActionsPanel(),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 36,
      height: 36,
      margin: EdgeInsets.only(left: isUser ? 0 : 8, right: isUser ? 8 : 0),
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.medical_services,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildStatusIcon() {
    Color iconColor;
    switch (widget.status) {
      case MessageStatus.sending:
        iconColor = Colors.grey.shade400;
        break;
      case MessageStatus.sent:
        iconColor = Colors.grey.shade400;
        break;
      case MessageStatus.delivered:
        iconColor = Colors.grey.shade400;
        break;
      case MessageStatus.read:
        iconColor = Colors.blue.shade300;
        break;
      case MessageStatus.failed:
        iconColor = Colors.red.shade400;
        break;
    }

    switch (widget.status) {
      case MessageStatus.sending:
        return Icon(Icons.access_time, size: 14, color: iconColor);
      case MessageStatus.sent:
        return Icon(Icons.check, size: 14, color: iconColor);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 14, color: iconColor);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 14, color: iconColor);
      case MessageStatus.failed:
        return Icon(Icons.error, size: 14, color: iconColor);
    }
  }

  Widget _buildReactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: widget.reactions!.map((reaction) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              reaction,
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReactionsPanel() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReactionButton('👍'),
              _buildReactionButton('👎'),
              _buildReactionButton('❤️'),
              _buildReactionButton('😂'),
              _buildReactionButton('😮'),
              _buildReactionButton('😢'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionButton(String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showReactionsPanel = false;
        });
        if (widget.onReaction != null) {
          widget.onReaction!(emoji);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  Widget _buildActionsPanel() {
    final isUser = widget.message.isUser;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onReply != null)
                _buildActionButton(
                  icon: Icons.reply,
                  tooltip: 'پاسخ',
                  onTap: () {
                    setState(() {
                      _showActions = false;
                    });
                    widget.onReply!();
                  },
                ),
              if (widget.onForward != null)
                _buildActionButton(
                  icon: Icons.forward,
                  tooltip: 'فوروارد',
                  onTap: () {
                    setState(() {
                      _showActions = false;
                    });
                    widget.onForward!();
                  },
                ),
              if (isUser && widget.onEdit != null)
                _buildActionButton(
                  icon: Icons.edit,
                  tooltip: 'ویرایش',
                  onTap: () {
                    setState(() {
                      _showActions = false;
                    });
                    widget.onEdit!();
                  },
                ),
              if (widget.onDelete != null)
                _buildActionButton(
                  icon: Icons.delete,
                  tooltip: 'حذف',
                  onTap: () {
                    setState(() {
                      _showActions = false;
                    });
                    widget.onDelete!();
                  },
                ),
              _buildActionButton(
                icon: Icons.emoji_emotions,
                tooltip: 'واکنش',
                onTap: () {
                  setState(() {
                    _showReactionsPanel = !_showReactionsPanel;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Icon(icon, size: 22, color: AppConstants.primaryColor),
        ),
      ),
    );
  }
}
