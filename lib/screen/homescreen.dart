import 'package:flutter/material.dart';
import 'package:khel_hisab/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khel_hisab/screen/continue_match_screen.dart';
import 'package:khel_hisab/screen/new_match_screen.dart';
import 'package:khel_hisab/screen/match_history_screen.dart';
import 'package:khel_hisab/screen/about_app_screen.dart';
import 'package:khel_hisab/screen/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<bool> _isMatchInProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('saved_match');
  }

  void _showNewMatchConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('A match is already in progress'),
          content: const Text(
            'Do you want to discard the current match and start a new one?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('saved_match');
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewMatchScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khel Hisab'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🆕 New Match
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                if (await _isMatchInProgress()) {
                  _showNewMatchConfirmationDialog();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewMatchScreen(),
                    ),
                  );
                }
              },
              child: const Text('🆕 New Match'),
            ),

            const SizedBox(height: 20),

            // ▶️ Continue Match
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                if (await _isMatchInProgress()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContinueMatchScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No ongoing match found.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('▶️ Continue Match'),
            ),

            const SizedBox(height: 20),

            // 📜 Match History
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchHistoryScreen(),
                  ),
                );
              },
              child: const Text('📜 Match History'),
            ),

            const SizedBox(height: 20),

            // ⚙️ Settings
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              child: const Text('⚙️ Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
