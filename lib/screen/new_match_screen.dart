import 'package:flutter/material.dart';
import 'package:khel_hisab/screen/scorecard_screen.dart';

enum MatchType { friendly, tournament }


class NewMatchScreen extends StatefulWidget {
  const NewMatchScreen({super.key});

  @override
  State<NewMatchScreen> createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends State<NewMatchScreen> {
  final _teamAController = TextEditingController(text: 'Team A');
  final _teamBController = TextEditingController(text: 'Team B');
  final _pointsPerSetController = TextEditingController(text: '10');
  final _setsToWinController = TextEditingController(text: '5');
  final _formKey = GlobalKey<FormState>();
  MatchType _selectedMatchType = MatchType.friendly;

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _pointsPerSetController.dispose();
    _setsToWinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _teamAController,
                  decoration: const InputDecoration(labelText: 'first team name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the first team name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _teamBController,
                  decoration: const InputDecoration(labelText: 'second team nam'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the second team name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _pointsPerSetController,
                  decoration: const InputDecoration(labelText: 'points per set'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter points per set';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _setsToWinController,
                  decoration: const InputDecoration(labelText: 'sets to win'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter sets to win';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Match Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                RadioListTile<MatchType>(
                  title: const Text('Friendly Match'),
                  value: MatchType.friendly,
                  groupValue: _selectedMatchType,
                  onChanged: (MatchType? value) {
                    setState(() {
                      _selectedMatchType = value!;
                    });
                  },
                ),
                RadioListTile<MatchType>(
                  title: const Text('Tournament Match'),
                  value: MatchType.tournament,
                  groupValue: _selectedMatchType,
                  onChanged: (MatchType? value) {
                    setState(() {
                      _selectedMatchType = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScorecardScreen(
                                teamAName: _teamAController.text,
                                teamBName: _teamBController.text,
                                pointsPerSet:
                                    int.parse(_pointsPerSetController.text),
                                setsToWin: int.parse(_setsToWinController.text),
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('▶️ Start Match'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('❌ Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
