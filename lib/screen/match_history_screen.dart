import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:khel_hisab/models/match_model.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  List<Match> matches = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('completed_matches') ?? [];

    setState(() {
      matches = history
          .map((e) => Match.fromJson(jsonDecode(e)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match History')),
      body: matches.isEmpty
          ? const Center(child: Text('No completed matches yet'))
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return ListTile(
                  title: Text('${match.teamA} vs ${match.teamB}'),
                  subtitle: Text(
                    'Sets: ${match.setsWonByA} - ${match.setsWonByB}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Optional: Match Details Screen
                  },
                );
              },
            ),
    );
  }
}
