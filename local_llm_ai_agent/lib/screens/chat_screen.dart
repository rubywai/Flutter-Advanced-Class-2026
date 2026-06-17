import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:local_llm_ai_agent/const/chat_message_mapper.dart';
import 'package:local_llm_ai_agent/data/models/response_model.dart';

import '../const/api_const.dart';
import '../data/chat_services/llm_chat_service.dart';
import '../data/models/chat_request_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final LlmChatService _chatService = LlmChatService();
  final TextEditingController _chatController = TextEditingController();
  bool _loading = false;
  final List<Message> _message = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Olla LLM Chat Agent")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _message.length + (_loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _message.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(),
                    );
                  }
                  Message message = _message[index];
                  bool isSender = message.role == "user";
                  return BubbleSpecialThree(
                    color: isSender ? Colors.blueAccent : Colors.black87,
                    text: message.content ?? "",
                    isSender: isSender,
                    textStyle: TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            SafeArea(
              child: TextField(
                controller: _chatController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: _chatController.text.trim().isEmpty
                        ? null
                        : () {
                            send(_chatController.text);
                          },
                    icon: Icon(Icons.send),
                  ),
                  labelText: "Enter your prompt",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void send(String prompt) {
    setState(() {
      _loading = true;
      _message.add(Message(role: "user", content: prompt));
    });
    _chatController.clear();
    _chatService
        .sendChat(
          chatRequestModel: ChatRequestModel(
            model: ApiConst.modelName,
            messages: [
              ..._message.map((v){
                return toMessage(v);
              }),
              Messages(
                role: ApiConst.systemMessage["role"],
                content: ApiConst.systemMessage["content"],
              ),
              Messages(role: "user", content: prompt),
            ],
            stream: false,
            think: false,
          ),
        )
        .then((v) {
          setState(() {
            _loading = false;
            Message? response = v.message;
            if (response != null) {
              _message.add(response);
            }
          });
        });
  }
}
