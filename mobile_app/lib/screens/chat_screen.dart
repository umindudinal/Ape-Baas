import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverPhone;
  final String receiverImage;
  final String? bookingId;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhone = '',
    this.receiverImage = '',
    this.bookingId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _currentUserId = '';
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_id') ?? '';
    setState(() {
      _currentUserId = uid;
    });

    if (uid.isNotEmpty) {
      await _fetchMessages();
      // Start auto-polling every 3 seconds for live chat updating
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _fetchMessages(isBackground: true);
      });
    }
  }

  Future<void> _fetchMessages({bool isBackground = false}) async {
    if (_currentUserId.isEmpty || widget.receiverId.isEmpty) return;

    if (!isBackground && _isLoading == false) {
      setState(() => _isLoading = true);
    }

    final history = await ApiService.getChatHistory(
      user1: _currentUserId,
      user2: widget.receiverId,
    );

    if (mounted) {
      final isDifferent = _messages.length != history.length ||
          (_messages.isNotEmpty && history.isNotEmpty && (_messages.last['id'] ?? _messages.last['created_at']) != (history.last['id'] ?? history.last['created_at']));

      if (isDifferent || _isLoading) {
        setState(() {
          _messages = history;
          _isLoading = false;
        });

        if (isDifferent) {
          _scrollToBottom();
        }
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    _textController.clear();
    setState(() => _isSending = true);

    // Optimistically add message to UI
    final tempMsg = {
      'sender_id': _currentUserId,
      'receiver_id': widget.receiverId,
      'text': text,
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.add(tempMsg);
    });
    _scrollToBottom();

    final res = await ApiService.sendMessage(
      senderId: _currentUserId,
      receiverId: widget.receiverId,
      bookingId: widget.bookingId,
      text: text,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (res['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'පණිවිඩය යැවීමට නොහැකි විය.')),
        );
      } else {
        _fetchMessages(isBackground: true);
      }
    }
  }

  Future<void> _makePhoneCall() async {
    if (widget.receiverPhone.isEmpty || widget.receiverPhone == 'නොමැත') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('දුරකථන අංකය ලබා දී නොමැත.')),
      );
      return;
    }
    final cleanPhone = widget.receiverPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri.parse('tel:$cleanPhone');
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Could not launch phone call: $e");
    }
  }

  ImageProvider? _getImageProvider(String imageStr) {
    if (imageStr.trim().isEmpty) return null;
    if (imageStr.startsWith('http://') || imageStr.startsWith('https://')) {
      return NetworkImage(imageStr);
    }
    try {
      String cleanBase64 = imageStr;
      if (imageStr.contains(',')) {
        cleanBase64 = imageStr.split(',').last;
      }
      return MemoryImage(base64Decode(cleanBase64));
    } catch (e) {
      return null;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = _getImageProvider(widget.receiverImage);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.navyDark,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.navySubtle,
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Text(
                      widget.receiverName.isNotEmpty ? widget.receiverName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepNavy, fontSize: 15),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName.isNotEmpty ? widget.receiverName : 'පරිශීලකයා',
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'සක්‍රියයි (Online)',
                    style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (widget.receiverPhone.isNotEmpty && widget.receiverPhone != 'නොමැත')
            IconButton(
              icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 22),
              onPressed: _makePhoneCall,
              tooltip: 'ඇමතුමක් ගන්න',
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.deepNavy))
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg['sender_id'] == _currentUserId;
                          final timeStr = _formatTime(msg['created_at']);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe) ...[
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.navySubtle,
                                    backgroundImage: avatarImage,
                                    child: avatarImage == null
                                        ? Text(
                                            widget.receiverName.isNotEmpty ? widget.receiverName[0].toUpperCase() : 'U',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isMe ? AppColors.deepNavy : Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(20),
                                        topRight: const Radius.circular(20),
                                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                                        bottomRight: Radius.circular(isMe ? 4 : 20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg['text'] ?? '',
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            color: isMe ? Colors.white : AppColors.navyDark,
                                            height: 1.35,
                                          ),
                                        ),
                                        if (timeStr.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            timeStr,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isMe ? Colors.white70 : AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Message Input Field Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: TextField(
                        controller: _textController,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14.5, color: AppColors.navyDark),
                        decoration: const InputDecoration(
                          hintText: 'පණිවිඩයක් ලියන්න...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        onSubmitted: (val) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.deepNavy,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: AppColors.navySubtle,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.deepNavy),
          ),
          const SizedBox(height: 14),
          Text(
            '${widget.receiverName} සමඟ සංවාදය ආරම්භ කරන්න',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'සේවා විස්තර හෝ වේලාවන් සකස් කරගැනීමට මෙහිදී පණිවිඩ යැවිය හැක.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
