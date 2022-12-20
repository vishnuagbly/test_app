import 'objects/basic_pgn.dart';

void main() {
  final history = History();
  history.addMove('', '34');
  history.addMove('34', 'as');
  history.addMove('34', '23');
  history.addMove('23', 'sd');
  print(history.tree);
}
