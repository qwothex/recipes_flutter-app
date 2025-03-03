import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class recipesModel {
  String id;
  String name;
  String description;
  String image;

  recipesModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });

  factory recipesModel.fromMap(Map<String, dynamic> map) {
    return recipesModel(
      id: (map['id'] as String), 
      name: map['name'] as String,
      description: map['description'] as String,
      image: getImageUrl(map['image']), 
    );
  }

  static String getImageUrl(String imageUrl) {
    final supabase = Supabase.instance.client;
    var url = supabase.storage.from("recipes_images").getPublicUrl(imageUrl);
    if(url.isNotEmpty){
      return url;
    }
    throw Exception('error');
  }

  static Future<List<recipesModel>> getRecipes() async {
    final supabase = Supabase.instance.client;
    final data = await supabase
      .from('recipes')
      .select('id, name, description, image');
    if(data.isNotEmpty) {
        return data.map<recipesModel>((recipe) =>
        recipesModel(
          id: (recipe['id'] as String),
          name: recipe['name'] as String,
          description: recipe['description'] as String,
          image: getImageUrl(recipe['image']),
        )).toList();
      }
      throw Exception('error');
  }
}

class ParsedRecipe {
  final String id;
  final String created_at;
  final String name;
  final String description;
  final String image;
  final List<IngredientEntry> ingredients;
  final List<StepEntry> steps;
  final double rating;

  ParsedRecipe({
    required this.id,
    required this.created_at,
    required this.name,
    required this.description,
    required this.image,
    required this.ingredients,
    required this.steps,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': created_at,
      'name': name,
      'description': description,
      'image': image,
      'ingredients': ingredients.map((item) => item.toJson()).toList(),
      'steps': steps.map((item) => item.toJson()).toList(),
      'rating': rating,
    };
  }

  static Future<ParsedRecipe> getRecipeById(String recipeId) async {
    final supabase = Supabase.instance.client;
    final data = await supabase
      .from('recipes')
      .select()
      .eq('id', recipeId);
    if(data.isNotEmpty){
      return await ParsedRecipe.fromMapAsync(data.first);
    }
    throw Exception('error');
  }

  static Future<List<IngredientEntry>> getIngredients(String ingredientsId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('ingredients')
      .select()
      .eq('id', ingredientsId)
      .maybeSingle(); 

  if (data != null) {
    return (jsonDecode(data['ingredients']) as List<dynamic>) 
        .map((item) => IngredientEntry.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  return []; 
}

  static Future<List<StepEntry>> getSteps(String stepsId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('steps')
      .select()
      .eq('id', stepsId)
      .maybeSingle(); 

  if (data != null) {
    return (jsonDecode(data['steps']) as List<dynamic>) 
        .map((item) => StepEntry.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  return []; 
}

  static Future<ParsedRecipe> fromMapAsync(Map<String, dynamic> map) async {
    List<IngredientEntry> ingredients = await getIngredients(map['ingredients']);
    List<StepEntry> steps = await getSteps(map['steps']);

    return ParsedRecipe(
      id: map['id'] as String? ?? '',
      created_at: map['created_at'] as String? ?? '',
      name: map['name'] as String? ?? 'No name',
      description: map['description'] as String? ?? 'No description',
      image: recipesModel.getImageUrl(map['image'] as String? ?? ''),
      ingredients: ingredients,
      steps: steps,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecipeIngredients {
  final String id;
  final DateTime createdAt;
  final List<IngredientEntry> ingredients;

  RecipeIngredients({
    required this.id,
    required this.createdAt,
    required this.ingredients,
  });

  factory RecipeIngredients.fromMap(Map<String, dynamic> map) {
    return RecipeIngredients(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at']), 
      ingredients: (jsonDecode(map['ingredients']) as List<dynamic>)
          .map((item) => IngredientEntry.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class IngredientEntry {
  final double quantity;
  final String name;

  IngredientEntry({required this.quantity, required this.name});

  factory IngredientEntry.fromMap(Map<String, dynamic> map) {
    return IngredientEntry(
      quantity: (map['quantity'] as num).toDouble(),
      name: map['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'name': name,
    };
  }
}

class StepEntry {
  final String title;
  final String description;

  StepEntry({required this.title, required this.description});

  factory StepEntry.fromMap(Map<String, dynamic> map) {
    return StepEntry(
      title: map['title'] as String? ?? 'No title',
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}