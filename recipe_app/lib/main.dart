import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/UI/pages/home_page.dart';
import 'package:recipe_app/UI/pages/recipe_page.dart';
import 'package:recipe_app/app_localizations.dart';
import 'package:recipe_app/state/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  
  await Supabase.initialize(
    url: 'https://pljgirwlbpojxkdaebhy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsamdpcndsYnBvanhrZGFlYmh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg5MjQ4OTEsImV4cCI6MjA1NDUwMDg5MX0.Eqmzju6Bi4zBGy2eH7hgfQB9Idk0qjQVApuGKZe21aw',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => StateProvider(),
      lazy: false,
      child: MainApp(),
    ), 
  );
}

class MainApp extends StatelessWidget {

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<StateProvider>().locale;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/recipe': (context) => RecipePage(),
      },
      
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
      ),

      locale: locale,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en'), 
        Locale('tr'), 
      ],

      localeResolutionCallback: (locale, supportedLocales) {
        return supportedLocales.contains(locale) ? locale : const Locale('en');
      },
    );
  }
}