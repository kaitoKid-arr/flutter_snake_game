import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/pages/blank_pixel.dart';
import 'package:snake_game/pages/food_pixel.dart';
import 'package:snake_game/pages/highscore_tile.dart';
import 'package:snake_game/pages/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // Grid dimensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  // Game settings
  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  // User score
  int currentScore = 0;

  // Snake position
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  // Snake direction is initially to the right
  var currentDirection = snake_Direction.RIGHT;

  // Food position
  int foodPos = 56;

  // Highscore list
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) {
              highscore_DocIds.add(element.reference.id);
            },
          ),
        );
  }

  // Start the game!
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        // Keep the snake moving!
        moveSnake();

        // Check if the game is over
        if (gameOver()) {
          timer.cancel();

          // Display a message to the user
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('It\'s over, Kamu terlalu cupu'),
                content: Column(
                  children: [
                    Text('Your score is ' + currentScore.toString()),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: 'Enter name'),
                    )
                  ],
                ),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      submitScore();
                      Navigator.pop(context);
                      submitScore();
                      newGame();
                    },
                    child: Text('Submit'),
                    color: Colors.pink,
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  void submitScore() {
    // Get access to the collection
    var database = FirebaseFirestore.instance;

    // Add data to firebase
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    // Making sure the new food is not where the snake is
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          // Add a new head
          // if snake is a the right wall, need to re-adjust
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;

      case snake_Direction.LEFT:
        {
          // Add a new head
          // if snake is a the right wall, need to re-adjust
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;

      case snake_Direction.UP:
        {
          // Add a new head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;

      case snake_Direction.DOWN:
        {
          // Add a new head
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;

      default:
    }
    // Snake is eating food
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      // Remove the tail
      snakePos.removeAt(0);
    }
  }

  // Game over
  bool gameOver() {
    // The game is over when the snake runs into itself
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains(snakePos.last)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Note: Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != snake_Direction.UP) {
            currentDirection = snake_Direction.DOWN;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
              currentDirection != snake_Direction.DOWN) {
            currentDirection = snake_Direction.UP;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != snake_Direction.LEFT) {
            currentDirection = snake_Direction.RIGHT;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != snake_Direction.RIGHT) {
            currentDirection = snake_Direction.LEFT;
          }
        },
        child: SizedBox(
          width: screenWidth > 428 ? 428 : screenWidth,
          child: Column(
            children: [
              // Note: High scores
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // User current score
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentScore.toString(),
                            style: TextStyle(fontSize: 36),
                          ),
                          Text('Current score'),
                        ],
                      ),
                    ),
                    // Highscore, top 5 or 10
                    Expanded(
                      child: gameHasStarted
                          ? Container()
                          : FutureBuilder(
                              future: letsGetDocIds,
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  itemCount: highscore_DocIds.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return HighScoreTile(
                                      documentId: highscore_DocIds[index],
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              // Note: Game Grid
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currentDirection != snake_Direction.UP) {
                      print('Move down');
                      currentDirection = snake_Direction.DOWN;
                    } else if (details.delta.dy < 0 &&
                        currentDirection != snake_Direction.DOWN) {
                      print("Move up");
                      currentDirection = snake_Direction.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currentDirection != snake_Direction.LEFT) {
                      print('Move right');
                      currentDirection = snake_Direction.RIGHT;
                    } else if (details.delta.dx < 0 &&
                        currentDirection != snake_Direction.RIGHT) {
                      print("Move left");
                      currentDirection = snake_Direction.LEFT;
                    }
                  },
                  child: GridView.builder(
                    itemCount: totalNumberOfSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                    itemBuilder: (context, index) {
                      if (snakePos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodPos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    },
                  ),
                ),
              ),
              // Note: Play button
              Expanded(
                child: Container(
                  child: Center(
                    child: MaterialButton(
                      child: Text('Play'),
                      color: gameHasStarted ? Colors.grey : Colors.pink,
                      onPressed: gameHasStarted ? () {} : startGame,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
