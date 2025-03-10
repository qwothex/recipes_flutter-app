import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/UI/chat/TestChat.dart';
import 'package:recipe_app/UI/widgets/AppBar.dart';
import 'package:recipe_app/UI/widgets/RecipesList.dart';
import 'package:recipe_app/state/provider.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  ParsedRecipe? recipe;
  bool isLoading = true;
  String? errorMessage;

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

    var id = ModalRoute.of(context)!.settings.arguments as String;
    final locale = context.read<StateProvider>().locale;

    ParsedRecipe.getRecipeById(id, locale).then((data) {
      if (mounted) {
        setState(() {
          recipe = data;
          isLoading = false;
        });

        final provider = context.read<StateProvider>();
        provider.setRecipe(data);
        provider.setsessionActive(true);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          errorMessage = "Error: $error";
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    return Scaffold(
      appBar: appBar(true, recipe!.name, context),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(recipe!.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(recipe!.name, style: const TextStyle(fontSize: 32)),
              Row(
                children: [
                  const Text('By user | '),
                  Text(recipe!.created_at.substring(0, 10)),
                ],
              ),
              const SizedBox(height: 15),
              Text(recipe!.description, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 25),
              const Text('Ingredients', style: TextStyle(fontSize: 24)),
              ...recipe!.ingredients.map((entry) => ListTile(
                    title: Text('${entry.quantity} ${entry.name}', style: const TextStyle(fontSize: 20)),
                  )),
              const SizedBox(height: 25),
              const Text('Get started', style: TextStyle(fontSize: 24)),
              ...recipe!.steps.map((entry) => ListTile(
                    title: Text(entry.title, style: const TextStyle(fontSize: 24)),
                    subtitle: Text(entry.description, style: const TextStyle(fontSize: 22)),
                  )),
              const SizedBox(height: 30),
            ],
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: ChatBotForm(),
          ),
        ],
      ),
    );
  }
}
