import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';
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
  var historial = <WordPair>[];
  var index = -1;

  GlobalKey? historialListKey;

  void getSiguiente() {
    if (index > 0) {
      --index;
      current = historial.elementAt(index);
    }else{
      if (!historial.contains(current)) {
        historial.insert(0, current);
        var animatedList = historialListKey?.currentState as AnimatedListState?;
        animatedList?.insertItem(0);
      }
      current = WordPair.random();
      index = -1;
    }
    notifyListeners();
    // historial.insert(0, current);
    // var animatedList = historialListKey?.currentState as AnimatedListState?;
    // animatedList?.insertItem(0);
    // current = WordPair.random();
    // notifyListeners();
  }

  void getAnterior(){
    if (index < historial.length-1) {
      if (index == -1) {
        historial.insert(0, current);
        var animatedList = historialListKey?.currentState as AnimatedListState?;
        animatedList?.insertItem(0);
        ++index;
      }
      ++index;
      current = historial.elementAt(index);
    }
    notifyListeners();
  }
  void toggleFavoritos({WordPair? idea}) {
    idea = idea?? current; 
    if (favoritos.contains(idea)) {
      favoritos.remove(idea);
    } else {
      favoritos.add(idea);
    }
    notifyListeners();
  }

  void eliminar ([WordPair? idea]){
    favoritos.remove(idea);
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
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritosPage();
        break;
      default:
        throw UnimplementedError('No hay widgets para: $selectedIndex');
    }
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home), label: Text("Inicio")),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite), label: Text("Favoritos"))
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
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
              )
            ),
          ]
          );
          }else{
            return Column(
              children: [
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page,
                  ),
                ),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: "Favoritos"
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: 	(value){
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  )
                )
              ],
            );
          }
        }
      )
    );
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
          Expanded(
            flex: 3,
            child: HistorialListView()
            ),
            SizedBox(height: 20,),
          BigCard(idea: appState.current),
          SizedBox(
            height: 100.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    appState.getAnterior();
                  },
                  icon: Icon(Icons.arrow_left),
                  label: Text("Anterior")),
              SizedBox(
                width: 20.0,
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavoritos(idea: idea);
                  },
                  icon: Icon(icon),
                  label: Text("Favorito")),
              SizedBox(
                width: 20.0,
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    appState.getSiguiente();
                  },
                  icon: Icon(Icons.arrow_right),
                  label: Text("Siguiente"),
              ),
            ],
          ),
          Spacer(flex: 3),
        ],
      ),
    );
  }
}

class FavoritosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favoritos.isEmpty) {
      return Center(
        child: Text("No hay favoritos aun"),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("Total de favoritos: ${appState.favoritos.length} "),
        ),
        for (var name in appState.favoritos)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete_outline, semanticLabel: 'Eliminar'),
              color: Theme.of(context).colorScheme.primary,
              onPressed: (){
                appState.eliminar(name);
              },
              ),
            title: Text(name.asLowerCase),
          )
      ],
    );
  }
}

class HistorialListView extends StatefulWidget {
  const HistorialListView({super.key});

  @override
  State<HistorialListView> createState() => _HistorialListView();
}

class _HistorialListView extends State<HistorialListView> {
  final _key = GlobalKey();
  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historialListKey = _key;
    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        initialItemCount: appState.historial.length,
        itemBuilder: (context, index, animation) {
          final idea = appState.historial[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                  onPressed: () {
                    appState.toggleFavoritos(idea: idea);
                  },
                  icon: appState.favoritos.contains(idea)
                      ? Icon(
                          Icons.favorite,
                          size: 12,
                        )
                      : SizedBox(),
                  label: Text(
                    idea.asLowerCase,
                    semanticsLabel: idea.asPascalCase,
                  )),
            ),
          );
        },
      ),
    );
  }
}
