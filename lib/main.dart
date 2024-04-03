import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(SnakeGame());

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF101010),
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)),
      ),
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final int squaresPerRow = 20;
  final int squaresPerCol = 40;
  final randomGen = Random();
  List<Point> snake = [Point(5, 5)];
  Point direction = Point(1, 0);
  Point? food;
  bool isPlaying = false;

  void startGame() {
    snake = [Point(5, 5)];
    direction = Point(1, 0);
    isPlaying = true;
    food = Point(randomGen.nextInt(squaresPerRow), randomGen.nextInt(squaresPerCol));

    Timer.periodic(Duration(milliseconds: 300), (Timer timer) {
      moveSnake();
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void moveSnake() {
    setState(() {
      final newHead = snake.first + direction;
      snake.insert(0, newHead);
      if (newHead == food) {
        food = Point(randomGen.nextInt(squaresPerRow), randomGen.nextInt(squaresPerCol));
      } else {
        snake.removeLast();
      }
    });
  }

  bool checkGameOver() {
    return !isPlaying ||
        snake.first.x < 0 ||
        snake.first.x >= squaresPerRow ||
        snake.first.y < 0 ||
        snake.first.y >= squaresPerCol ||
        snake.skip(1).contains(snake.first);
  }

  void endGame() {
    isPlaying = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your game is over, but you can always start over.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (direction != Point(0, 1) && details.delta.dy > 0) {
            direction = Point(0, 1);
          } else if (direction != Point(0, -1) && details.delta.dy < 0) {
            direction = Point(0, -1);
          }
        },
        onHorizontalDragUpdate: (details) {
          if (direction != Point(1, 0) && details.delta.dx > 0) {
            direction = Point(1, 0);
          } else if (direction != Point(-1, 0) && details.delta.dx < 0) {
            direction = Point(-1, 0);
          }
        },
        child: GridView.builder(
          itemCount: squaresPerRow * squaresPerCol,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: squaresPerRow,
          ),
          itemBuilder: (BuildContext context, int index) {
            var color;
            var x = index % squaresPerRow;
            var y = index ~/ squaresPerRow;

            bool isSnakeBody = snake.contains(Point(x, y));
            bool isSnakeHead = snake.first == Point(x, y);
            bool isFood = food == Point(x, y);

            if (isSnakeHead) {
              color = Colors.green[700];
            } else if (isSnakeBody) {
              color = Colors.green[500];
            } else if (isFood) {
              color = Colors.red[500];
            } else {
              color = Colors.grey[900];
            }

            return Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startGame,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}

extension on Point {
  Point operator +(Point other) {
    return Point(x + other.x, y + other.y);
  }
}
