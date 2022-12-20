import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_app/objects/basic_pgn.dart';

final historyProvider = ChangeNotifierProvider<History>((ref) => History());

final moveProvider = ChangeNotifierProvider.family<Move?, String>(
  (ref, text) =>
      ref.watch(historyProvider.select((history) => history.tree[text])),
);

final selectedMoveProvider = StateProvider<String>((ref) => '');
