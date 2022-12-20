import 'package:flutter/cupertino.dart';

class Move extends ChangeNotifier {
  Move(this.id, this.text) : next = [];

  final String id;
  final String text;
  final List<String> next;

  @override
  String toString() {
    return '($text $next)';
  }

  void addNextMove(String move) {
    next.add(move);
    notifyListeners();
  }
}

class History extends ChangeNotifier {
  History() : tree = {'': Move('', '')};

  final Map<String, Move> tree;

  static const String _pgnRegEx =
      r'^(((([KQRBN])?|P?)x?([a-h][1-8]?)?[a-h][1-8](=[KQRBN])?)|(O-O(-O)?))(\+|#)?$';

  void addMove(String lastMove, String nextMove) {
    if (!RegExp(_pgnRegEx).hasMatch(nextMove)) {
      throw ArgumentError('Move does not match the PGN Notation');
    }
    if (!tree.containsKey(lastMove)) {
      throw ArgumentError('Last move not exists');
    }
    final move = Move('${tree[lastMove]!.id}/$nextMove', nextMove);
    if (tree.containsKey(move.id)) {
      throw ArgumentError('Same move already made');
    }
    tree[move.id] = move;
    tree[lastMove]!.addNextMove(move.id);
    notifyListeners();
  }
}
