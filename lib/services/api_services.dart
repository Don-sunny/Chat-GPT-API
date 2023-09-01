import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatgpt_app/constants/api_const.dart';
import 'package:chatgpt_app/models/chat_model.dart';
import 'package:chatgpt_app/models/models_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static Future<List<ModelsModel>> getModels() async {
    debugPrint('Function called');
    try {
      var response = await http.get(
        Uri.parse('$BASE_URL/models'),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );
      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error']${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }
      // print('jsonResponse: $jsonResponse');
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        debugPrint("Temp ${value['id']}");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      log('Error: $error');
      rethrow;
    }
  }

  // send meassage fact
  static Future<List<ChatModel>> sendMeassage(
      {required String message, required String modelId}) async {
    debugPrint('Function called');
    try {
      var response = await http.post(Uri.parse('$BASE_URL/completions'),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "model": modelId,
            "prompt": message,
            "max_tokens": 100,
          }));
      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error']${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
              msg: jsonResponse["choices"][index]["text"], chataIndex: 1),
        );
        debugPrint(
            'jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}');
      }
      return chatList;
    } catch (error) {
      log('Error: $error');
      rethrow;
    }
  }
}
