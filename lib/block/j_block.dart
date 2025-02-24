import 'package:flutter/material.dart';
import 'package:flutter_block_game/block/block.dart';

class JBlock extends Block {
  JBlock()
    : super(
        shape: [
          [0, 1],
          [0, 1],
          [1, 1],
        ],
        color: Colors.blue,
      );

  @override
  Block clone() {
    return JBlock(); // ✨ 새로운 JBlock 객체 생성
  }
}
