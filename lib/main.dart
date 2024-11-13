import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/Control_page.dart';
import 'pages/Run_page.dart';
import 'pages/Add_light_page.dart';
import 'pages/Wemcome_page.dart';

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
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
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
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
