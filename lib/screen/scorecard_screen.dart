import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';


class ScorecardScreen extends StatefulWidget {
  final String teamAName;
  final String teamBName;
  final int pointsPerSet;
  final int setsToWin;

  const ScorecardScreen({
    super.key,
    required this.teamAName,
    required this.teamBName,
    required this.pointsPerSet,
    required this.setsToWin,
  });

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  int _teamAScore = 0;
  int _teamBScore = 0;
  int _teamASetsWon = 0;
  int _teamBSetsWon = 0;
  int _currentSet = 1;

  void _incrementScore(int team) {
    setState(() {
      if (team == 1) {
        _teamAScore++;
      } else {
        _teamBScore++;
      }
      _checkSetWin();
    });
  }

  void _checkSetWin() {
    if (_teamAScore >= widget.pointsPerSet && _teamAScore >= _teamBScore + 2) {
      _teamASetsWon++;
      _resetSet();
    } else if (_teamBScore >= widget.pointsPerSet &&
        _teamBScore >= _teamAScore + 2) {
      _teamBSetsWon++;
      _resetSet();
    }
    _checkMatchWin();
  }

  void _checkMatchWin() {
    if (_teamASetsWon >= widget.setsToWin) {
      _showWinnerDialog(widget.teamAName);
    } else if (_teamBSetsWon >= widget.setsToWin) {
      _showWinnerDialog(widget.teamBName);
    }
  }

  void _resetSet() {
    setState(() {
      _teamAScore = 0;
      _teamBScore = 0;
      _currentSet++;
    });
  }

  Future<void> _showWinnerDialog(String winner) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Match Over'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$winner wins the match!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('New Match'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
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
              pw.Header(
                level: 0,
                text: 'Khel Hisab - Match Scorecard',
              ),
              pw.Paragraph(
                text: 'Match between ${widget.teamAName} and ${widget.teamBName}',
              ),
              pw.SizedBox(height: 20),
              pw.Text('Current Set: $_currentSet'),
              pw.SizedBox(height: 10),
              pw.Text('Sets Won:'),
              pw.Text('${widget.teamAName}: $_teamASetsWon'),
              pw.Text('${widget.teamBName}: $_teamBSetsWon'),
              pw.SizedBox(height: 20),
              pw.Text('Current Set Score:'),
              pw.Text('${widget.teamAName}: $_teamAScore'),
              pw.Text('${widget.teamBName}: $_teamBScore'),
              pw.SizedBox(height: 20),
              pw.Paragraph(text: 'Match Settings:'),
              pw.Text('Points per Set: ${widget.pointsPerSet}'),
              pw.Text('Sets to Win: ${widget.setsToWin}'),
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
        title: Text('Set $_currentSet / ${widget.setsToWin * 2 - 1}'),
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
                Text('${widget.teamAName}: $_teamASetsWon sets', style: Theme.of(context).textTheme.headlineSmall),
                Text('${widget.teamBName}: $_teamBSetsWon sets', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(widget.teamAName, style: Theme.of(context).textTheme.headlineMedium),
                    Text('$_teamAScore', style: Theme.of(context).textTheme.displayLarge),
                    ElevatedButton(
                      onPressed: () => _incrementScore(1),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        textStyle: const TextStyle(fontSize: 24),
                      ),
                      child: const Text('+1'),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(widget.teamBName, style: Theme.of(context).textTheme.headlineMedium),
                    Text('$_teamBScore', style: Theme.of(context).textTheme.displayLarge),
                    ElevatedButton(
                      onPressed: () => _incrementScore(2),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        textStyle: const TextStyle(fontSize: 24)
                      ),
                      child: const Text('+1'),
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
