// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recipe_app/UI/widgets/RecipesList.dart';

class StateProvider with ChangeNotifier {
  ParsedRecipe? _recipe;
  String _speechResult = '';

  ParsedRecipe? get recipe => _recipe;
  String get speechResult => _speechResult;

  void setRecipe(ParsedRecipe recipe) {
    _recipe = recipe;
    notifyListeners();
  }

  void setSpeechResult(Map<String, dynamic> result) {
    // print(result);
    _speechResult = result['answer']!;
    // print('a' + _speechResult);
    notifyListeners();
  }
}
