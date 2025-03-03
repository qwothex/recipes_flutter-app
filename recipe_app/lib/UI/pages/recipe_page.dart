import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/UI/chat/TestChat.dart';
import 'package:recipe_app/UI/widgets/AppBar.dart';
import 'package:recipe_app/UI/widgets/RecipesList.dart';
import 'package:recipe_app/state/provider.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    final stateProvider = context.read<StateProvider>();
    var id = ModalRoute.of(context)!.settings.arguments as String;

    return FutureBuilder(
      future: ParsedRecipe.getRecipeById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        ParsedRecipe recipe = snapshot.data!;
        Future.microtask(() => stateProvider.setRecipe(recipe));
        

        return Scaffold(
          appBar: appBar(true, recipe.name, context),
          body: Stack(
            children: [
              ListView(
              padding: EdgeInsets.only(left: 20, right: 20),
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(recipe.image),
                      alignment: Alignment.topLeft,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  mainAxisSize: MainAxisSize.min, 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    Row(
                      children: [
                        Text('By user | '),
                        Text(DateTime.parse(recipe.created_at).toString().substring(0, 10)),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      recipe.description,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 24
                      ),
                    ),
                    Column(
                      children: recipe.ingredients.asMap().values.map((entry) {
                        return ListTile(
                            title: Text(
                              '${entry.quantity} ${entry.name}',
                              style: TextStyle(
                                fontSize: 20
                              ),
                            ),
                          );
                      }).toList()
                    ),
                    SizedBox(height: 25),
                    Text(
                      'Get started',
                      style: TextStyle(
                        fontSize: 24
                      ),
                    ),
                    Column(
                      children: recipe.steps.asMap().values.map((entry) {
                        return ListTile(
                            title: Text(
                              entry.title,
                              style: TextStyle(
                                fontSize: 24
                              ),
                            ),
                            subtitle: Text(
                              entry.description,
                              style: TextStyle(
                                fontSize: 22
                              ),
                            ),
                          );
                      }).toList()
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ChatBotForm(),
            )
            ]
          ),
        );
      },
    );
  }
}
