import 'package:flutter/material.dart';

class FilterModel {
  final String id;
  final String name;
  final String category;
  final Color previewColor;
  final List<double> colorMatrix;
  final String description;
  final IconData iconData;
  final String? arEffect; // Optional AR effect identifier like 'neon_halo', 'cyber_visor'

  const FilterModel({
    required this.id,
    required this.name,
    required this.category,
    required this.previewColor,
    required this.colorMatrix,
    required this.description,
    required this.iconData,
    this.arEffect,
  });

  bool get isNormal => id == 'filter_01';
}
