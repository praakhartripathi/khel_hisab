import 'package:flutter/material.dart';
import 'package:khel_hisab/models/match_model.dart';
import 'package:khel_hisab/screen/new_match_screen.dart';
import 'package:khel_hisab/screen/scorecard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
import 'package:khel_hisab/screen/homescreen.dart';

class ContinueMatchScreen extends StatefulWidget {
  const ContinueMatchScreen({super.key});
  
    @override
  State<ContinueMatchScreen> createState() => _ContinueMatchScreenState();
}

class _ContinueMatchScreenState extends State<ContinueMatchScreen> {
  Match? _savedMatch;
  bool _matchExists = false;

  @override
  void initState() {
    super.initState();
    _loadMatch();
  }

  Future<void> _loadMatch() async {
    final prefs = await SharedPreferences.getInstance();
    final matchJson = prefs.getString('saved_match');
    if (matchJson != null) {
      setState(() {
        _savedMatch = Match.fromJson(jsonDecode(matchJson));
        _matchExists = true;
      });
    }
  }

  Future<void> _deleteMatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_match');
    setState(() {
      _savedMatch = null;
      _matchExists = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Match'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _matchExists && _savedMatch != null
            ? _buildSavedMatchView(_savedMatch!)
            : _buildNoMatchView(),
      ),
    );
  }

  Widget _buildSavedMatchView(Match match) {
    final String lastUpdated = timeago.format(match.lastUpdated);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '${match.teamA} vs ${match.teamB}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  'Set ${match.currentSetNumber} | Score ${match.teamAScore} - ${match.teamBScore}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Last updated: $lastUpdated',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ScorecardScreen(match: _savedMatch),
              ),
            );
          },
          icon: const Text('▶️', style: TextStyle(fontSize: 20)),
          label: const Text('Resume match'),
        ),
      ],
    );
  }

  Widget _buildNoMatchView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'No ongoing match found.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NewMatchScreen()),
              );
            },
            child: const Text('start a new match'),
          ),
        ],
      ),
    );
  }
}
