class recipesModel {
  int id;
  String name;
  String imgPath;
  String description;

  recipesModel({
    required this.id,
    required this.name,
    required this.imgPath,
    required this.description,
  });

  static List < recipesModel > getrecipes() {
    List < recipesModel > recipes = [];

    recipes.add(
      recipesModel(
       id: 0,
       name: 'Touchdown Pizza',
       imgPath: 'assets/images/pizza.webp',
       description: 'My favorite sports pub serves this, and I`ve come up with a simple and delicious home version. It`s rich, so serve in squares as an appetizer. Serve ranch dressing, celery, and carrot sticks on the side. Enjoy!'
      )
    );

    recipes.add(
      recipesModel(
       id: 1,
       name: 'Hot Dog Burnt Ends',
       imgPath: 'assets/images/ends.webp',
       description: 'These charred hot dog burnt ends are crispy, juicy, and simply delicious. Serve with mustard for dipping'
      )
    );

    recipes.add(
      recipesModel(
       id: 2,
       name: 'Juicy Gourmet Burger Sliders',
       imgPath: 'assets/images/burger.webp',
       description: 'If you want to kick up your regular burger a few notches and get more dinner-table approval grunts, this is a sure thing. Juicy, super-flavourful, and can be an appetizer (sliders) or full sized burgers. Enjoy!'
      )
    );

    return recipes;
  }

  static recipesModel getRecipeById(int recipeId) {
    return getrecipes().firstWhere(
      (recipe) => recipe.id == recipeId,
      orElse: () => throw Exception('Recipe not found'),
    );
  }
}
