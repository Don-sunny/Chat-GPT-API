class ChatModel {
  final String msg;
  final int chataIndex;
  ChatModel({
    required this.msg,
    required this.chataIndex,
  });
  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        msg: json["msg"],
        chataIndex: json["chatIndex"],
      );
}
