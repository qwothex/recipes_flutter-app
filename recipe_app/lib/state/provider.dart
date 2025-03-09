import 'package:flutter/material.dart';
import 'package:recipe_app/UI/widgets/RecipesList.dart';

class SessionItem {
  final String? text;
  final Map<String, dynamic>? data;
  final Widget? widget;

  SessionItem({this.text, this.data, this.widget});
}

class StateProvider with ChangeNotifier {
  ParsedRecipe? _recipe;
  String _speechResult = '';
  bool _sessionActive = false;
  List<SessionItem> _sessionMessages = [];

  ParsedRecipe? get recipe => _recipe;
  String get speechResult => _speechResult;
  bool get isSessionActive => _sessionActive;
  List<SessionItem> get sessionMessages => _sessionMessages;

  void setRecipe(ParsedRecipe recipe) {
    _recipe = recipe;
    notifyListeners();
  }

  void setSpeechResult(Map<String, dynamic> result) {
    _speechResult = result['answer']!;
    notifyListeners();
  }

  void clearSpeechResult() {
    _speechResult = '';
    notifyListeners();
  }

  void setsessionActive(bool value) {
    _sessionActive = value;
    notifyListeners();
  }

  void addSessionMessage(SessionItem message){
    if(message.data != null){
      print(message.data);
    }
    sessionMessages.add(message);
    notifyListeners();
  }

  void removeLoader(){
    sessionMessages.removeLast();
    notifyListeners();
  }
}
