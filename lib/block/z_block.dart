import 'package:flutter/material.dart';
import 'package:flutter_block_game/block/block.dart';

class ZBlock extends Block {
  ZBlock()
    : super(
        shape: [
          [1, 1, 0],
          [0, 1, 1],
        ],
        color: Colors.red,
      );

  @override
  Block clone() {
    return ZBlock(); // ✨ 새로운 ZBlock 객체 생성
  }
}
