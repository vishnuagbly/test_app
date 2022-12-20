import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/history.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PGN Test App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Move',
              ),
              onFieldSubmitted: (text) {
                setState(() {
                  try {
                    ref
                        .read(historyProvider)
                        .addMove(ref.read(selectedMoveProvider), text);
                  } catch (err) {
                    String message = '$err';
                    if (err is ArgumentError) {
                      message = err.message;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                });
                log('${ref.read(historyProvider).tree}', name: '$this');
              },
            ),
            const SizedBox(height: 10),
            const MovesList(prevMoveId: '', scroll: true),
          ],
        ),
      ),
    );
  }
}

class MovesList extends ConsumerStatefulWidget {
  const MovesList({
    Key? key,
    this.prevMoveId = '',
    this.scroll = false,
  }) : super(key: key);

  final String prevMoveId;
  final bool scroll;

  @override
  ConsumerState createState() => _HistoryDisplayState();
}

class _HistoryDisplayState extends ConsumerState<MovesList> {
  final moves = <MoveWidget>[];

  @override
  Widget build(BuildContext context) {
    final move = ref.watch(moveProvider(widget.prevMoveId));
    final nextMoves = move?.next ?? [];
    if (moves.length < nextMoves.length) {
      final currentTotalMoves = moves.length;
      for (int i = currentTotalMoves; i < nextMoves.length; i++) {
        moves.add(MoveWidget(
          moveId: nextMoves[i],
          scroll: widget.scroll,
        ));
      }
    }

    log('building prevMove: ${widget.prevMoveId} nextMoves: ${nextMoves.length} widgets: ${moves.length}',
        name: '$this');

    Widget res = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: moves,
    );

    if (widget.scroll) {
      res = SingleChildScrollView(
        child: res,
      );
    }

    return res;
  }
}

class MoveWidget extends ConsumerWidget {
  const MoveWidget({
    Key? key,
    this.moveId = '',
    this.scroll = false,
  }) : super(key: key);

  final String moveId;
  final bool scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('building move: $moveId', name: '$this');
    final isSelected =
        ref.watch(selectedMoveProvider.select((move) => move == moveId));
    final move = ref.read(moveProvider(moveId));

    Widget res = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? Colors.white10 : Colors.transparent,
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text('${move?.text}'),
          ),
          onTap: () {
            ref.read(selectedMoveProvider.notifier).state =
                isSelected ? '' : moveId;
          },
        ),
        MovesList(prevMoveId: moveId),
      ],
    );

    if (scroll) {
      res = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: res,
      );
    }

    return res;
  }
}
