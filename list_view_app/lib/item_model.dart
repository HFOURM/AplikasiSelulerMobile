import 'package:flutter/foundation.dart';

@immutable
class ItemModel {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;

  const ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  /// Creates a copy of this model with optionally overridden fields.
  ItemModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) =>
      ItemModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Serialise to a map for persistence in SharedPreferences.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        // Store as epoch millis – avoids ISO-string timezone ambiguity.
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  /// Deserialise from a map loaded from SharedPreferences.
  factory ItemModel.fromMap(Map<String, dynamic> map) => ItemModel(
        id: (map['id'] as num).toInt(),
        name: map['name'] as String,
        description: map['description'] as String,
        createdAt: map['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                (map['createdAt'] as num).toInt(),
              )
            : DateTime.now(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ItemModel(id: $id, name: $name)';
}