import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/UI/widgets/AppBar.dart';
import 'package:recipe_app/UI/widgets/Button.dart';
import 'package:recipe_app/UI/widgets/RecipesList.dart';
import 'package:recipe_app/state/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  List<recipesModel> recipes = [];
  bool isLoading = true;
  String imageUrl = '';
  Locale? locale;

    void fetchRecipes() async{
    if(locale != null){
      var data = await recipesModel.getRecipes(locale!);
      if(data.isNotEmpty){
        setState(() {
          recipes = data;
          isLoading = false; 
        });  
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      locale = context.watch<StateProvider>().locale;
    });

    fetchRecipes();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: appBar(false, 'Recipes', context),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/aigen.webp"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                'Search among 1000 recipes', 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white
                ),
              ),
            )
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 15, right: 15, top: 25),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    FilterButton(text: 'Soup'),
                    SizedBox(height: 15),
                    FilterButton(text: 'Dinner'),
                  ]
                ),
                Column(
                  children: [
                    FilterButton(text: 'Dessert'),
                    SizedBox(height: 15),
                    FilterButton(text: 'Breakfast'),
                  ]
                )
              ],
            ),
          ),
          SizedBox(height: 25,),
          Text(
            'Recommendation', 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32
            ),
          ),
          Container(
            width: double.infinity,
            height: 600,
            child: 
              isLoading ? 
                Center(child: CircularProgressIndicator())
              :
            ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 25,),
            itemCount: recipes.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){
                  Navigator.pushNamed(
                    context, 
                    '/recipe',
                    arguments: recipes[index].id
                  );}, 
                child: Container(
                  margin: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(recipes[index].image),
                              fit: BoxFit.fitWidth,
                            )
                          ),
                        ),
                        Text(
                          recipes[index].name, 
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 32,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          recipes[index].description, 
                          textAlign: TextAlign.center,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
