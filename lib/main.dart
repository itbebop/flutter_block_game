import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'block/block.dart';
import 'block/j_block.dart';
import 'block/l_block.dart';
import 'block/s_block.dart';
import 'block/z_block.dart';

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
  Offset? touchOffset; // 블록 내에서 터치한 상대 위치
  Map<int, Offset> gridPositions = {}; // 그리드 위치 저장

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

  static const int gridSize = 9;
  List<List<bool>> grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
  bool isClearing = false;
  final AudioPlayer player = AudioPlayer();

  void placeBlock(Block block, int row, int col, int touchedRow, int touchedCol) {
    setState(() {
      // Calculate the top-left corner of the block placement
      int baseRow = row - touchedRow;
      int baseCol = col - touchedCol;

      // Check if the block fits within the grid boundaries
      if (baseRow < 0 || baseCol < 0 || baseRow + block.shape.length > gridSize || baseCol + block.shape[0].length > gridSize) {
        return; // Exit if placement is invalid
      }

      // Check for overlaps with existing blocks in the grid
      for (int r = 0; r < block.shape.length; r++) {
        for (int c = 0; c < block.shape[r].length; c++) {
          if (block.shape[r][c] == 1 && grid[baseRow + r][baseCol + c]) {
            return; // Exit if any part of the block overlaps
          }
        }
      }

      // Place the block on the grid
      for (int r = 0; r < block.shape.length; r++) {
        for (int c = 0; c < block.shape[r].length; c++) {
          if (block.shape[r][c] == 1) {
            grid[baseRow + r][baseCol + c] = true;
          }
        }
      }

      // Clear selected block and generate new preview blocks
      selectedBlock = null;
      generatePreviewBlocks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("9x9 블록 퍼즐")),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (groupRow) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (groupCol) {
                          return buildGridGroup(groupRow * 3, groupCol * 3);
                        }),
                      );
                    }),
                  ),
                ),
              ),
              Divider(thickness: 3, color: Colors.black),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      previewBlocks.map((block) {
                        return GestureDetector(
                          onPanStart: (details) {
                            print("onPanStart, block: $block details.globalPosition: ${details.globalPosition}, touchOffset: ${details.localPosition}");
                            setState(() {
                              selectedBlock = block; // 선택한 블록
                              blockPosition = details.globalPosition; // 드래그 시작 위치
                              touchOffset = details.localPosition; // 블록 내 터치한 상대 위치
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              blockPosition = details.globalPosition;
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              blockPosition = null;
                              selectedBlock = null;
                            });
                          },
                          child: buildBlockPreview(block),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
          if (selectedBlock != null && blockPosition != null)
            Positioned(left: blockPosition!.dx - (touchOffset?.dx ?? 0), top: blockPosition!.dy - (touchOffset?.dy ?? 0), child: buildBlockPreview(selectedBlock!)),
        ],
      ),
    );
  }

  Widget buildGridGroup(int startRow, int startCol) {
    return Container(
      margin: EdgeInsets.all(2),
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
      child: Column(
        children: List.generate(3, (rowOffset) {
          return Row(
            children: List.generate(3, (colOffset) {
              int row = startRow + rowOffset;
              int col = startCol + colOffset;
              return DragTarget<Block>(
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (data) {
                  placeBlock(data.data, row, col, touchOffset!.dy.toInt(), touchOffset!.dx.toInt());
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 35,
                    height: 35,
                    margin: EdgeInsets.all(1),
                    decoration: BoxDecoration(color: grid[row][col] ? Colors.blue : Colors.grey[300], border: Border.all(color: Colors.grey, width: 0.5)),
                  );
                },
              );
            }),
          );
        }),
      ),
    );
  }

  Widget buildBlockPreview(Block block) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (col) {
              bool isFilled = row < block.shape.length && col < block.shape[row].length ? block.shape[row][col] == 1 : false;
              return Container(width: 20, height: 20, margin: EdgeInsets.all(2), color: isFilled ? block.color : Colors.transparent);
            }),
          );
        }),
      ),
    );
  }
}
