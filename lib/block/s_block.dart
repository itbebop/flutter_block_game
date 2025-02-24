import 'package:flutter/material.dart';
import 'package:flutter_block_game/block/block.dart';

class SBlock extends Block {
  SBlock()
    : super(
        shape: [
          [0, 1, 1],
          [1, 1, 0],
        ],
        color: Colors.green,
      );
  @override
  Block clone() {
    return SBlock(); // ✨ 새로운 SBlock 객체 생성
  }
}
