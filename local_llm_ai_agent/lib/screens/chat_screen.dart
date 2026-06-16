import 'package:flutter/material.dart';

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
  String _answer = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Olla LLM Chat Agent")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: Column(
              children: [
                if(_loading) CircularProgressIndicator(),
                if(!_loading) Text(_answer),

              ],
            )),
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
       _answer = "";
     });
    _chatService
        .sendChat(
          chatRequestModel: ChatRequestModel(
            model: ApiConst.modelName,
            messages: [
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
            _answer = v.message?.content ?? "";
          });
        });
  }
}
