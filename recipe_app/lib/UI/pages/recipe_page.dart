import 'package:flutter/material.dart';
import 'package:recipe_app/UI/widgets/AppBar.dart';
import 'package:recipe_app/UI/widgets/RecipesList.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {

  final int id = ModalRoute.of(context)!.settings.arguments as int;

  recipesModel recipe = recipesModel.getRecipeById(id);

    return Scaffold(
      appBar: appBar(true, recipe.name, context),
      body: ListView(
        padding: EdgeInsets.only(left: 20, right: 20),
        children: [
          Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(recipe.imgPath),
                  alignment: Alignment.topLeft,
                  fit: BoxFit.cover
                ),
              ),
            ),
            SizedBox(height: 20,),
            Column(
              children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                recipe.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 32,
                )
              ),
              ),
              Row(
                children: [
                  Text('By user | '),
                  Text('17 Feb 2025')
                ],
              )
              ],
            ),
            SizedBox(height: 20,),
            Text(
              recipe.description,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 26,
              )
            ),
          ],
        ),
        ],
      ),
    );
  }
}