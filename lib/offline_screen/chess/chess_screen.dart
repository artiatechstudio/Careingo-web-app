import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  final ChessBoardController _controller = ChessBoardController();
  
  int _whiteTimeMs = 10 * 60 * 1000;
  int _blackTimeMs = 10 * 60 * 1000;
  int _initialTimeMs = 10 * 60 * 1000;
  
  Timer? _timer;
  bool _isWhiteTurn = true;
  bool _gameStarted = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onBoardChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onBoardChanged);
    super.dispose();
  }

  void _onBoardChanged() {
    if (_gameOver) return;

    if (!_gameStarted && _controller.getPossibleMoves().length < 20) {
      _startGame();
    }

    final String fen = _controller.getFen();
    if (fen.split(' ').length > 1) {
      final isWhiteNow = fen.split(' ')[1] == 'w';
      if (_isWhiteTurn != isWhiteNow) {
        setState(() {
          _isWhiteTurn = isWhiteNow;
        });
      }
    }

    _checkGameStatus();
  }

  void _checkGameStatus() {
    if (_controller.isCheckMate()) {
      _endGame(_isWhiteTurn ? 'الأسود' : 'الأبيض', 'كش مات! فاز اللاعب ${_isWhiteTurn ? 'الأسود' : 'الأبيض'}');
    } else if (_controller.isDraw() || _controller.isStaleMate() || _controller.isThreefoldRepetition() || _controller.isInsufficientMaterial()) {
      _endGame('تعادل', 'انتهت اللعبة بالتعادل.');
    }
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_isWhiteTurn) {
          _whiteTimeMs -= 100;
          if (_whiteTimeMs <= 0) {
            _whiteTimeMs = 0;
            _endGame('الأسود', 'انتهى وقت الأبيض! فاز اللاعب الأسود.');
          }
        } else {
          _blackTimeMs -= 100;
          if (_blackTimeMs <= 0) {
            _blackTimeMs = 0;
            _endGame('الأبيض', 'انتهى وقت الأسود! فاز اللاعب الأبيض.');
          }
        }
      });
    });
  }

  void _endGame(String winner, String message) {
    if (_gameOver) return;
    _timer?.cancel();
    setState(() {
      _gameOver = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('نهاية اللعبة'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('لعب مجدداً'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    _timer?.cancel();
    _controller.resetBoard();
    setState(() {
      _whiteTimeMs = _initialTimeMs;
      _blackTimeMs = _initialTimeMs;
      _isWhiteTurn = true;
      _gameStarted = false;
      _gameOver = false;
    });
  }

  void _setTimer(int minutes) {
    if (_gameStarted) return;
    setState(() {
      _initialTimeMs = minutes * 60 * 1000;
      _whiteTimeMs = _initialTimeMs;
      _blackTimeMs = _initialTimeMs;
    });
  }

  String _formatTime(int ms) {
    int totalSeconds = ms ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشطرنج'),
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            onSelected: _setTimer,
            icon: const Icon(Icons.timer),
            tooltip: 'تحديد الوقت',
            itemBuilder: (context) => [
              const PopupMenuItem(value: 3, child: Text('3 دقائق')),
              const PopupMenuItem(value: 5, child: Text('5 دقائق')),
              const PopupMenuItem(value: 10, child: Text('10 دقائق')),
              const PopupMenuItem(value: 30, child: Text('30 دقيقة')),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Black Player Info
            Container(
              padding: const EdgeInsets.all(16.0),
              color: !_isWhiteTurn && _gameStarted && !_gameOver ? Colors.blue.shade100 : Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('اللاعب الأسود', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_formatTime(_blackTimeMs), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ChessBoard(
                    controller: _controller,
                    boardColor: BoardColor.green,
                    boardOrientation: PlayerColor.white,
                  ),
                ),
              ),
            ),
            
            // White Player Info
            Container(
              padding: const EdgeInsets.all(16.0),
              color: _isWhiteTurn && _gameStarted && !_gameOver ? Colors.blue.shade100 : Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('اللاعب الأبيض', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_formatTime(_whiteTimeMs), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _controller.undoMove();
                    },
                    icon: const Icon(Icons.undo),
                    label: const Text('تراجع'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _gameStarted && !_gameOver
                        ? () => _endGame(_isWhiteTurn ? 'الأسود' : 'الأبيض', 'انسحب اللاعب ${_isWhiteTurn ? 'الأبيض' : 'الأسود'}! فاز ${_isWhiteTurn ? 'الأسود' : 'الأبيض'}')
                        : null,
                    icon: const Icon(Icons.flag),
                    label: const Text('انسحاب'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
