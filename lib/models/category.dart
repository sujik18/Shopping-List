import 'package:flutter/material.dart';

enum Categories{
  vegetables,
  fruits,
  dairy,
  meat,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

class Category {
  final String name;
  final Color color;

  const Category(this.name, this.color);
}