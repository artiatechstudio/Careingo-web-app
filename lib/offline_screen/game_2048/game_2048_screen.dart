
import 'dart:math';
import 'package:flutter/material.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  List<List<int>> _grid = List.generate(4, (_) => List.generate(4, (_) => 0));
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _grid = List.generate(4, (_) => List.generate(4, (_) => 0));
    _score = 0;
    _addNumber();
    _addNumber();
    setState(() {});
  }

  void _addNumber() {
    List<Point<int>> emptyTiles = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (_grid[i][j] == 0) {
          emptyTiles.add(Point(i, j));
        }
      }
    }

    if (emptyTiles.isNotEmpty) {
      final random = Random();
      int index = random.nextInt(emptyTiles.length);
      Point<int> pos = emptyTiles[index];
      _grid[pos.x][pos.y] = random.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    double dx = details.primaryVelocity!.dx;
    double dy = details.primaryVelocity!.dy;

    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        _moveRight();
      } else {
        _moveLeft();
      }
    } else {
      if (dy > 0) {
        _moveDown();
      } else {
        _moveUp();
      }
    }
  }

  void _moveLeft() {
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<int> row = _grid[i];
      List<int> newRow = _transform(row);
      if (row.toString() != newRow.toString()) {
        moved = true;
      }
      _grid[i] = newRow;
    }
    if (moved) {
      _addNumber();
      setState(() {});
    }
  }

  void _moveRight() {
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<int> row = _grid[i].reversed.toList();
      List<int> newRow = _transform(row);
      if (_grid[i].toString() != newRow.reversed.toList().toString()) {
        moved = true;
      }
      _grid[i] = newRow.reversed.toList();
    }
    if (moved) {
      _addNumber();
      setState(() {});
    }
  }

  void _moveUp() {
    bool moved = false;
    for (int j = 0; j < 4; j++) {
      List<int> col = [];
      for (int i = 0; i < 4; i++) {
        col.add(_grid[i][j]);
      }
      List<int> newCol = _transform(col);
      if (col.toString() != newCol.toString()) {
        moved = true;
      }
      for (int i = 0; i < 4; i++) {
        _grid[i][j] = newCol[i];
      }
    }
    if (moved) {
      _addNumber();
      setState(() {});
    }
  }

  void _moveDown() {
    bool moved = false;
    for (int j = 0; j < 4; j++) {
      List<int> col = [];
      for (int i = 3; i >= 0; i--) {
        col.add(_grid[i][j]);
      }
      List<int> newCol = _transform(col);
      if (col.reversed.toList().toString() != newCol.toString()) {
        moved = true;
      }
      for (int i = 3; i >= 0; i--) {
        _grid[i][j] = newCol[3 - i];
      }
    }
    if (moved) {
      _addNumber();
      setState(() {});
    }
  }

  List<int> _transform(List<int> list) {
    List<int> newList = List.filled(4, 0);
    int i = 0;
    for (int j = 0; j < 4; j++) {
      if (list[j] != 0) {
        newList[i++] = list[j];
      }
    }

    for (int j = 0; j < 3; j++) {
      if (newList[j] != 0 && newList[j] == newList[j + 1]) {
        newList[j] *= 2;
        _score += newList[j];
        for (int k = j + 1; k < 3; k++) {
          newList[k] = newList[k + 1];
        }
        newList[3] = 0;
      }
    }
    return newList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048 Game'),
      ),
      body: GestureDetector(
        onVerticalDragEnd: _handleSwipe,
        onHorizontalDragEnd: _handleSwipe,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $_score',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _startGame,
                    child: const Text('New Game'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  int row = index ~/ 4;
                  int col = index % 4;
                  int value = _grid[row][col];
                  return Container(
                    decoration: BoxDecoration(
                      color: _getTileColor(value),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        value == 0 ? '' : value.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: value > 4 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.grey[300]!;
      case 4:
        return Colors.grey[400]!;
      case 8:
        return Colors.orange[300]!;
      case 16:
        return Colors.orange[400]!;
      case 32:
        return Colors.orange[500]!;
      case 64:
        return Colors.orange[600]!;
      case 128:
        return Colors.red[300]!;
      case 256:
        return Colors.red[400]!;
      case 512:
        return Colors.red[500]!;
      case 1024:
        return Colors.red[600]!;
      case 2048:
        return Colors.red[700]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
