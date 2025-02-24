import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_block_game/block/block.dart';
import 'package:flutter_block_game/block/j_block.dart';
import 'package:flutter_block_game/block/l_block.dart';
import 'package:flutter_block_game/block/s_block.dart';
import 'package:flutter_block_game/block/z_block.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: GameScreen());
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<Block> blockPool = [JBlock(), LBlock(), SBlock(), ZBlock()];
  List<Block> previewBlocks = [];
  Block? selectedBlock;
  Offset? blockPosition;
  Offset? touchOffset;
  bool isDragging = false;

  static const int gridSize = 9;
  static const double cellSize = 35;

  List<List<bool>> grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
  List<List<bool>> ghostGrid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));

  @override
  void initState() {
    super.initState();
    generatePreviewBlocks();
  }

  void generatePreviewBlocks() {
    final random = Random();
    setState(() {
      previewBlocks = List.generate(3, (_) => blockPool[random.nextInt(blockPool.length)].clone());
    });
  }

  Widget buildGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(gridSize, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(gridSize, (col) {
            return Container(
              width: cellSize,
              height: cellSize,
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: ghostGrid[row][col] ? Colors.yellow.withOpacity(0.7) : (grid[row][col] ? Colors.blue : Colors.grey[300]),
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget buildPreviewArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          previewBlocks.map((block) {
            return GestureDetector(
              onPanStart: (details) {
                setState(() {
                  selectedBlock = block.clone();
                  blockPosition = details.globalPosition;
                  touchOffset = details.localPosition;
                  isDragging = false;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  blockPosition = details.globalPosition;

                  if (!isDragging && (blockPosition! - touchOffset!).distance >= cellSize * 1.5) {
                    isDragging = true;
                  }

                  if (isDragging) {
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
                    int row = (localOffset.dy / cellSize).floor();
                    int col = (localOffset.dx / cellSize).floor();
                    updateGhostGrid(row, col);
                  }
                });
              },
              onPanEnd: (_) {
                setState(() {
                  if (isDragging && canPlaceBlock()) {
                    placeSelectedBlock();
                  }
                  selectedBlock = null;
                  blockPosition = null;
                  ghostGrid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
                  isDragging = false;
                });
              },
              child: buildPreview(block),
            );
          }).toList(),
    );
  }

  Widget buildPreview(Block block) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          block.shape.map((row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  row.map((cell) {
                    return Container(
                      width: cellSize,
                      height: cellSize,
                      margin: EdgeInsets.all(1),
                      decoration: BoxDecoration(color: cell == 1 ? block.color.withOpacity(0.5) : Colors.transparent, border: cell == 1 ? Border.all(color: Colors.black) : null),
                    );
                  }).toList(),
            );
          }).toList(),
    );
  }

  void updateGhostGrid(int row, int col) {
    setState(() {
      ghostGrid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));

      if (selectedBlock == null) return;

      for (int r = 0; r < selectedBlock!.shape.length; r++) {
        for (int c = 0; c < selectedBlock!.shape[r].length; c++) {
          if (selectedBlock!.shape[r][c] == 1) {
            int gridRow = row + r;
            int gridCol = col + c;

            if (gridRow >= 0 && gridRow < gridSize && gridCol >= 0 && gridCol < gridSize) {
              ghostGrid[gridRow][gridCol] = true;
            }
          }
        }
      }
    });
  }

  bool canPlaceBlock() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (ghostGrid[row][col] && grid[row][col]) {
          return false;
        }
      }
    }
    return true;
  }

  void placeSelectedBlock() {
    if (selectedBlock == null) return;
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (ghostGrid[row][col]) {
          grid[row][col] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Block Game')), body: Column(children: [buildPreviewArea(), Expanded(child: buildGrid())]));
  }
}
