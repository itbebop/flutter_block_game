import 'package:flutter/material.dart';

abstract class Block {
  List<List<int>> shape;
  Color color;

  Block({required this.shape, required this.color});

  Block clone(); // ✨ 복사 메서드 추가
}
