class Match {
  final String id;
  final String teamA;
  final String teamB;
  final int pointsPerSet;
  final int setsToWin;
  int currentSetNumber;
  int teamAScore;
  int teamBScore;
  int setsWonByA;
  int setsWonByB;
  DateTime lastUpdated;
  bool isCompleted;

  Match({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.pointsPerSet,
    required this.setsToWin,
    this.currentSetNumber = 1,
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.setsWonByA = 0,
    this.setsWonByB = 0,
    required this.lastUpdated,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamA': teamA,
      'teamB': teamB,
      'pointsPerSet': pointsPerSet,
      'setsToWin': setsToWin,
      'currentSetNumber': currentSetNumber,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'setsWonByA': setsWonByA,
      'setsWonByB': setsWonByB,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      teamA: json['teamA'],
      teamB: json['teamB'],
      pointsPerSet: json['pointsPerSet'],
      setsToWin: json['setsToWin'],
      currentSetNumber: json['currentSetNumber'],
      teamAScore: json['teamAScore'],
      teamBScore: json['teamBScore'],
      setsWonByA: json['setsWonByA'],
      setsWonByB: json['setsWonByB'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
