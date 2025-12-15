import 'dart:async';
import 'package:fisherman_pro/create_message_page.dart';
import 'package:flutter/material.dart';
import 'package:fisherman_pro/database/message_service.dart';
import 'package:fisherman_pro/models/message.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MessageService _messageService = MessageService();
  final Supabase _supabase = Supabase.instance;
  final TextEditingController _textController = TextEditingController();

  List<Message> _messages = [];
  bool _isLoading = true;
  Timer? _autoRefreshTimer;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.client.auth.currentUser?.id;
    _loadMessages();
    _subscribeToMessages();

    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadMessages();
      }
    });
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _supabase.client
          .from('messages')
          .select('*')
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map(
            (msg) => Message(
              id: msg['id']?.toString(),
              text: msg['text']?.toString(),
              imageUrl: msg['image_url']?.toString(),
              latitude: msg['latitude'] != null
                  ? double.parse(msg['latitude'].toString())
                  : null,
              longitude: msg['longitude'] != null
                  ? double.parse(msg['longitude'].toString())
                  : null,
              address: msg['address']?.toString(),
              userId: msg['user_id']?.toString(),
              userName: msg['user_name']?.toString() ?? 'Рыбак',
              createdAt: msg['created_at'] != null
                  ? DateTime.parse(msg['created_at'].toString())
                  : DateTime.now(),
            ),
          )
          .toList();

      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Ошибка загрузки сообщений: $e');
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToMessages() {
    _supabase.client.from('messages').stream(primaryKey: ['id']).listen((
      event,
    ) {
      _loadMessages();
    });
  }

  Future<void> _sendTextMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final text = _textController.text.trim();
    _textController.clear();

    try {
      await _messageService.sendMessage(
        text,
        null, // без фото
        null, // без координат
        null,
        null, // без адреса
      );
    } catch (e) {
      print('Ошибка отправки текстового сообщения: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка отправки: $e')));
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.grey.shade800,
                    ),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.waves,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Пока нет сообщений',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Начните общение первым!',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMyMessage = message.userId == _currentUserId;
                      return _buildMessageCard(message, isMyMessage);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Написать сообщение...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.photo_library,
                      color: Colors.grey.shade700,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateMessagePage(),
                        ),
                      );
                    },
                    tooltip: 'Добавить фото',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade900,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendTextMessage,
              tooltip: 'Отправить',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Message message, bool isMyMessage) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.5;
    final imageHeight = imageWidth * 0.75;
    final horizontalPadding = 8.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              radius: 20,
              child: Text(
                message.userName?[0].toUpperCase() ?? 'Р',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            SizedBox(width: 12),
          ],
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: isMyMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isMyMessage ? 0 : 4,
                    right: isMyMessage ? 4 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: isMyMessage
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isMyMessage) ...[
                        Text(
                          message.userName ?? 'Рыбак',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      Text(
                        DateFormat('HH:mm').format(message.createdAt!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (isMyMessage) ...[
                        SizedBox(width: 8),
                        Text(
                          'Вы',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: isMyMessage ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: isMyMessage
                          ? Radius.circular(12)
                          : Radius.circular(4),
                      bottomRight: isMyMessage
                          ? Radius.circular(4)
                          : Radius.circular(12),
                    ),
                    border: Border.all(
                      color: isMyMessage
                          ? Colors.grey.shade300
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.text != null && message.text!.isNotEmpty)
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.75,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Text(
                            message.text!,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      if (message.imageUrl != null)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft:
                                  message.text != null &&
                                      message.text!.isNotEmpty
                                  ? Radius.circular(0)
                                  : Radius.circular(8),
                              bottomRight:
                                  message.text != null &&
                                      message.text!.isNotEmpty
                                  ? Radius.circular(0)
                                  : Radius.circular(8),
                            ),
                            child: Container(
                              width: imageWidth,
                              height: imageHeight,
                              child: Image.network(
                                message.imageUrl!,
                                fit: BoxFit.cover,
                                width: imageWidth,
                                height: imageHeight,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: imageWidth,
                                        height: imageHeight,
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: imageWidth,
                                    height: imageHeight,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            color: Colors.grey.shade500,
                                            size: 40,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Ошибка загрузки',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      if (message.address != null)
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.75,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  message.address!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                    left: isMyMessage ? 0 : 4,
                    right: isMyMessage ? 4 : 0,
                  ),
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(message.createdAt!),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
          if (isMyMessage) ...[
            SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              radius: 20,
              child: Text(
                _supabase.client.auth.currentUser?.email?[0].toUpperCase() ??
                    'Я',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
