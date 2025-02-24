import 'package:flutter/material.dart';
import 'package:flutter_block_game/block/block.dart';

class LBlock extends Block {
  LBlock()
    : super(
        shape: [
          [1, 0],
          [1, 0],
          [1, 1],
        ],
        color: Colors.orange,
      );
  @override
  Block clone() {
    // ✨ 새로운 LBlock 객체 생성
    return LBlock();
  }
}
