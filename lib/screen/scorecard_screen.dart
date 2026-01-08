import 'package:flutter/material.dart';
import 'package:khel_hisab/models/match_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import 'package:khel_hisab/screen/new_match_screen.dart';

class ScorecardScreen extends StatefulWidget {
  final Match? match;
  final String? teamAName;
  final String? teamBName;
  final int? pointsPerSet;
  final int? setsToWin;

  const ScorecardScreen({
    super.key,
    this.match,
    this.teamAName,
    this.teamBName,
    this.pointsPerSet,
    this.setsToWin,
  }) : assert(
         match != null ||
             (teamAName != null &&
                 teamBName != null &&
                 pointsPerSet != null &&
                 setsToWin != null),
       );

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  late Match _match;
  bool _isContinuedMatch = false;

  @override
  void initState() {
    super.initState();
    if (widget.match != null) {
      _match = widget.match!;
      _isContinuedMatch = true;
    } else {
      _match = Match(
        id: DateTime.now().toIso8601String(),
        teamA: widget.teamAName!,
        teamB: widget.teamBName!,
        pointsPerSet: widget.pointsPerSet!,
        setsToWin: widget.setsToWin!,
        lastUpdated: DateTime.now(),
      );
    }
    _saveMatch();
  }

  Future<void> _saveMatch() async {
    final prefs = await SharedPreferences.getInstance();
    final matchJson = jsonEncode(_match.toJson());
    await prefs.setString('saved_match', matchJson);
  }

  void _incrementScore(int team) {
    setState(() {
      if (team == 1) {
        _match.teamAScore++;
      } else {
        _match.teamBScore++;
      }
      _match.lastUpdated = DateTime.now();
      _checkSetWin();
      _saveMatch();
    });
  }

  void _decrementScore(int team) {
    setState(() {
      if (team == 1 && _match.teamAScore > 0) {
        _match.teamAScore--;
      } else if (team == 2 && _match.teamBScore > 0) {
        _match.teamBScore--;
      }
      _match.lastUpdated = DateTime.now();
      _saveMatch();
    });
  }

  void _checkSetWin() {
    if (_match.teamAScore >= _match.pointsPerSet &&
        _match.teamAScore >= _match.teamBScore + 2) {
      _match.setsWonByA++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_match.teamA} won Set ${_match.currentSetNumber}!'),
          duration: const Duration(seconds: 2),
        ),
      );
      _resetSet();
    } else if (_match.teamBScore >= _match.pointsPerSet &&
        _match.teamBScore >= _match.teamAScore + 2) {
      _match.setsWonByB++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_match.teamB} won Set ${_match.currentSetNumber}!'),
          duration: const Duration(seconds: 2),
        ),
      );
      _resetSet();
    }
    _checkMatchWin();
  }

  void _checkMatchWin() {
    if (_match.setsWonByA >= _match.setsToWin) {
      _showWinnerDialog(_match.teamA);
    } else if (_match.setsWonByB >= _match.setsToWin) {
      _showWinnerDialog(_match.teamB);
    }
  }

  void _resetSet() {
    setState(() {
      _match.teamAScore = 0;
      _match.teamBScore = 0;
      _match.currentSetNumber++;
      _saveMatch();
    });
  }

  Future<void> _showWinnerDialog(String winner) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_match');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🏆 Match Over'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text('$winner Won the Match!')]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Match Over'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            TextButton(
              child: const Text('New Match'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
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

  Future<void> _generateAndSharePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'Khel Hisab - Match Scorecard'),
              pw.Paragraph(
                text: 'Match between ${_match.teamA} and ${_match.teamB}',
              ),
              pw.SizedBox(height: 20),
              pw.Text('Current Set: ${_match.currentSetNumber}'),
              pw.SizedBox(height: 10),
              pw.Text('Sets Won:'),
              pw.Text('${_match.teamA}: ${_match.setsWonByA}'),
              pw.Text('${_match.teamB}: ${_match.setsWonByB}'),
              pw.SizedBox(height: 20),
              pw.Text('Current Set Score:'),
              pw.Text('${_match.teamA}: ${_match.teamAScore}'),
              pw.Text('${_match.teamB}: ${_match.teamBScore}'),
              pw.SizedBox(height: 20),
              pw.Paragraph(text: 'Match Settings:'),
              pw.Text('Points per Set: ${_match.pointsPerSet}'),
              pw.Text('Sets to Win: ${_match.setsToWin}'),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/scorecard.pdf");
    await file.writeAsBytes(await pdf.save());

    Share.shareXFiles([XFile(file.path)], text: 'Here is the match scorecard.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Set ${_match.currentSetNumber} / ${_match.setsToWin * 2 - 1}',
            ),
            if (_isContinuedMatch)
              const Text('(continue match)', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _generateAndSharePdf,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '${_match.teamA}: ${_match.setsWonByA} sets',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${_match.teamB}: ${_match.setsWonByB} sets',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      _match.teamA,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '${_match.teamAScore}',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _decrementScore(1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('-1'),
                        ),
                        ElevatedButton(
                          onPressed: () => _incrementScore(1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('+1'),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _match.teamB,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '${_match.teamBScore}',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _decrementScore(2),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(60, 50),
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            '-1',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),

                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _incrementScore(2),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('+1'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
