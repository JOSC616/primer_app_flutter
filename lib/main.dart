import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 140, 255)),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favoritos = <WordPair>[];
  void getSiguiente() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavoritos() {
    if (favoritos.contains(current)) {
      favoritos.remove(current);
    } else {
      favoritos.add(current);
    }
    notifyListeners();
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context){
    Widget page;
    switch(selectedIndex){
      case 0: page = GeneratorPage(); break;
      case 1: page = Placeholder(); break;
      default:
        throw UnimplementedError('No hay widgets para: $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(child: NavigationRail(
            extended: false,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home), 
                label: Text("Inicio")),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite), 
                  label: Text("Favoritos"))
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value){
              setState(() {
                selectedIndex = value;
              });
            },
          ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            )),
          ],
          ),
        )
    ;
  }
}

class BigCard extends StatelessWidget {
  final WordPair idea;
  const BigCard({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textStyle = tema.textTheme.displayMedium!.copyWith(
      color: tema.colorScheme.onPrimary,
    );
    return Card(
      color: tema.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          idea.asLowerCase,
          style: textStyle,
          semanticsLabel: "${idea.first} ${idea.second}",
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    IconData icon;
    var idea = appState.current;
    if (appState.favoritos.contains(idea)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border_outlined;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("idea"),
          BigCard(idea: appState.current),
          SizedBox(
            height: 100.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavoritos();
                  },
                  icon: Icon(icon),
                  label: Text("Favorito")),
              SizedBox(
                width: 20.0,
              ),
              ElevatedButton(
                  onPressed: () {
                    appState.getSiguiente();
                  },
                  child: Text("Siguiente")),
            ],
          ),
        ],
      ),
    );
  }
}
