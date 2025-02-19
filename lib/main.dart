import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
// import 'pages/TEST.dart';
import 'pages/RunStatusPage.dart';
import 'pages/RunSuccessionPage.dart'; // Import the new page

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Verrouiller l'application en mode paysage uniquement
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => ControllerModel(),
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundLit',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFF140D16),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final String espIp = 'http://192.168.1.112';

  // Liste des pages associées aux index de navigation
  final List<Widget> _pages = [
    const WelcomePage(),
    const ControlPage(),
    // RunPage(),
    const RunSuccessionPage(),
    const AddLightPage(),
    const ToolsPage(),
    const DatabaseResetPage(),
    const AddModelPage(),
    const UsedLightPage(),
    const StatuPage(),
    const ModelsScreen(),
    const AddUsedLightPage(),
    const UsedLightsPage(),
    const RunStatusPage(),
    // Add the new page
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
              decoration: const BoxDecoration(
                color: Color(0xFF1E1C1C),
              ),
              child: Image.asset(
                'assets/logo/logo.png', // Chemin vers votre logo
                width: 100, // Ajustez la largeur selon vos besoins
                height: 100, // Ajustez la hauteur selon vos besoins
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Welcome'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.control_camera),
              title: const Text('Control'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.run_circle),
              title: const Text('Run'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Add Light'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Tools'),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Delete database'),
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Add model page'),
              onTap: () => _onItemTapped(6),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Used light Crud'),
              onTap: () => _onItemTapped(7),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('State Crud'),
              onTap: () => _onItemTapped(8),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Show models'),
              onTap: () => _onItemTapped(9),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Add used Light'),
              onTap: () => _onItemTapped(10),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Show used Light'),
              onTap: () => _onItemTapped(11),
            ),
            ListTile(
              leading: const Icon(Icons.run_circle),
              title: const Text('Run statu'),
              onTap: () => _onItemTapped(12),
            ),
            // ListTile(
            //   leading: const Icon(Icons.run_circle),
            //   title: const Text('Run Succession'), // Add the new menu item
            //   onTap: () => _onItemTapped(13),
            // ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
