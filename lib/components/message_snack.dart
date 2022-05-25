import 'package:flutter/material.dart';
import 'dart:convert';

void Message_Snack(BuildContext context, String text) {
  SnackBar sb = SnackBar(
    duration: Duration(milliseconds: 2500),
    content: Text(
      _parseError(text),
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    ),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
      Radius.circular(20),
    )),
    elevation: 6.0,
    backgroundColor: Colors.black54,
    behavior: SnackBarBehavior.floating,
    width: MediaQuery.of(context).size.width / 2,
  );

  ScaffoldMessenger.of(context).showSnackBar(sb);
}

String _parseError(String text) {
  try
  {
    return errorMessageFromJson(text).error;
  }catch (e){
    return text;
  }
}

ErrorMessage errorMessageFromJson(String str) => ErrorMessage.fromJson(json.decode(str));

String errorMessageToJson(ErrorMessage data) => json.encode(data.toJson());

class ErrorMessage {
  ErrorMessage({
    required this.error,
  });

  String error;

  factory ErrorMessage.fromJson(Map<String, dynamic> json) => ErrorMessage(
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
  };
}

