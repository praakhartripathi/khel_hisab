import 'package:flutter/material.dart';
import 'package:khel_hisab/models/match_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  List<Match> _matchHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchHistory();
  }

  Future<void> _loadMatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? matchHistoryJson = prefs.getString('match_history');
    if (matchHistoryJson != null) {
      final List<dynamic> jsonList = jsonDecode(matchHistoryJson);
      setState(() {
        _matchHistory = jsonList.map((json) => Match.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearMatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('match_history');
    setState(() {
      _matchHistory = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Match history cleared!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _matchHistory.isEmpty ? null : _clearMatchHistory,
            tooltip: 'Clear Match History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matchHistory.isEmpty
              ? const Center(child: Text('No completed matches yet.'))
              : ListView.builder(
                  itemCount: _matchHistory.length,
                  itemBuilder: (context, index) {
                    final match = _matchHistory[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${match.teamA} vs ${match.teamB}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Final Score: ${match.setsWonByA} - ${match.setsWonByB} sets'),
                            Text(
                                'Points per Set: ${match.pointsPerSet}, Sets to Win: ${match.setsToWin}'),
                            Text(
                                'Completed on: ${match.lastUpdated.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}