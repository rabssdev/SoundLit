import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/Control_page.dart';
import 'pages/Run_page.dart';
import 'pages/Add_light_page.dart';
import 'pages/Wemcome_page.dart';
import 'pages/ToolsPage.dart';
import 'pages/database_reset.dart';
// import 'pages/ModelCrudPage.dart';
import 'pages/Used_light_CRUD.dart';
import 'pages/State_CRUD.dart';
import 'pages/Add_model_page.dart';
import 'pages/Show_models.dart';
import 'pages/Add_used_light.dart';
import 'pages/Show_used_light.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Verrouiller l'application en mode paysage uniquement
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundLit',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Color(0xFF140D16),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Liste des pages associées aux index de navigation
  final List<Widget> _pages = [
    WelcomePage(),
    ControlPage(),
    RunPage(),
    AddLightPage(),
    ToolsPage(),
    DatabaseResetPage(),
    AddModelPage(),
    UsedLightPage(),
    StatuPage(),
    ModelsScreen(),
    AddUsedLightPage(),
    UsedLightsPage(),
  ];

  // Méthode de changement de page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Ferme la barre latérale après la navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E1C1C),
              ),
              child: Image.asset(
                'assets/logo/logo.png', // Chemin vers votre logo
                width: 100, // Ajustez la largeur selon vos besoins
                height: 100, // Ajustez la hauteur selon vos besoins
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Welcome'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.control_camera),
              title: Text('Control'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.run_circle),
              title: Text('Run'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: Icon(Icons.lightbulb),
              title: Text('Add Light'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Tools'),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Delete database'),
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Add model page'),
              onTap: () => _onItemTapped(6),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Used light Crud'),
              onTap: () => _onItemTapped(7),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('State Crud'),
              onTap: () => _onItemTapped(8),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Show models'),
              onTap: () => _onItemTapped(9),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Add used Light'),
              onTap: () => _onItemTapped(10),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Show used Light'),
              onTap: () => _onItemTapped(11),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
