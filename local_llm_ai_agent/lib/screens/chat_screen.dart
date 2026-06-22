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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _chatController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Olla LLM Chat Agent")),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _message.length + (_loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _message.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Thinking..."),
                      );
                    }
                    Message message = _message[index];
                    bool isSender = message.role == "user";
                    if(message.content?.isEmpty == true){
                      return SizedBox.shrink();
                    }
                    return BubbleSpecialThree(
                      color: isSender ? Colors.blueAccent : Color(0xFFE8E8EE),
                      text: message.content ?? "",
                      isSender: isSender,
                      textStyle: isSender
                          ? TextStyle(color: Colors.white)
                          : TextStyle(),
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
                      onPressed: _chatController.text
                          .trim()
                          .isEmpty
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
      ),
    );
  }

  void send(String prompt) {
    setState(() {
      _loading = true;
      _message.add(Message(role: "user", content: prompt));
    });

    _chatController.clear();
    Message answer = Message(role: "assistance", content: "");
    bool isReceived = false;
    _chatService
        .sendChatStream(
      chatRequestModel: ChatRequestModel(
        model: ApiConst.modelName,
        messages: [
          ..._message.map((v) {
            return toMessage(v);
          }),
          Messages(
            role: ApiConst.systemMessage["role"],
            content: ApiConst.systemMessage["content"],
          ),
          Messages(role: "user", content: prompt),
        ],
        stream: true,
        think: false,
      ),
    )
        .listen((chunk) {
      setState(() {
        _loading = false;
        if (!isReceived) {
          _message.add(answer);
          isReceived = true;
        }
        answer.content =
            (answer.content ?? "") + (chunk.message?.content ?? "");
        List<ToolCalls> tools = chunk.message?.toolCalls ?? [];
        for (var tool in tools) {
          String? id = tool.id;
          String? name = tool.function?.name;
          if (name == "show_warning_dialog") {
            Arguments? arguments = tool.function?.arguments;
            String? title = arguments?.title;
            String? content = arguments?.content;
            if (title != null && content != null) {
              showWarningDialog(title, content);
            }
          }
        }
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  void showWarningDialog(String title, String content) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          FilledButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text("OK"),),
        ],
      );
    });
  }
}
