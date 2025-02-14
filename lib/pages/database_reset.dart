import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseResetPage extends StatelessWidget {
  const DatabaseResetPage({super.key});

  Future<void> _deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    await deleteDatabase(path);
    print('Base de données supprimée avec succès.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialisation de la Base de Données'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _deleteDatabase();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Base de données supprimée avec succès')),
            );
          },
          child: const Text('Supprimer la Base de Données'),
        ),
      ),
    );
  }
}
