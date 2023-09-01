import 'package:chatgpt_app/constants/constants.dart';
import 'package:chatgpt_app/models/chat_model.dart';

import 'package:chatgpt_app/providers/models_provider.dart';
import 'package:chatgpt_app/services/api_services.dart';
import 'package:chatgpt_app/services/assets_manager.dart';
import 'package:chatgpt_app/services/services.dart';
import 'package:chatgpt_app/widgets/chat_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late FocusNode focusNode;
  @override
  void initState() {
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
    focusNode.dispose();
  }

  List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetManager.chatLogo),
        ),
        title: const Text('ChatGpt'),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModelSheet(context: context);
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Flexible(
            child: ListView.builder(
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                return ChatWidget(
                  msg: chatList[index].msg,
                  chatIndex: int.parse(
                    chatList[index].chataIndex.toString(),
                  ),
                );
              },
            ),
          ),
          if (_isTyping) ...[
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 25,
            ),
          ],
          const SizedBox(
            height: 15,
          ),
          Material(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (value) async => await sendMessageFct(
                        modelsProvider: modelsProvider,
                      ),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'How can I help you',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async => await sendMessageFct(
                      modelsProvider: modelsProvider,
                    ),
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  Future<void> sendMessageFct({required modelsProvider}) async {
    try {
      setState(() {
        _isTyping = true;
        chatList.add(
          ChatModel(msg: textEditingController.text, chataIndex: 0),
        );
        textEditingController.clear();
        focusNode.unfocus();
      });
      debugPrint("Request has been sent");
      chatList.addAll(
        await ApiServices.sendMeassage(
          message: textEditingController.text,
          modelId: modelsProvider.getCurrentModel,
        ),
      );
      setState(() {});
    } catch (error) {
      debugPrint('what is Error: $error');
      textEditingController.clear();
      focusNode.unfocus();
    } finally {
      setState(() {
        _isTyping = false;
        textEditingController.clear();
        focusNode.unfocus();
      });
    }
  }
}
