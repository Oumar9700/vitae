import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/food_model.dart';

abstract class CiqualLocalDataSource {
  Future<List<FoodModel>> searchFood(String query);
}

class CiqualLocalDataSourceImpl implements CiqualLocalDataSource {
  List<Map<String, dynamic>>? _cache;

  Future<List<Map<String, dynamic>>> _load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/ciqual.json');
    final list = jsonDecode(raw) as List;
    _cache = list.cast<Map<String, dynamic>>();
    return _cache!;
  }

  @override
  Future<List<FoodModel>> searchFood(String query) async {
    final q = _normalize(query.trim());
    if (q.length < 2) return [];

    final words = q.split(' ').where((w) => w.length >= 2).toList();
    final data = await _load();

    final scored = <(int, Map<String, dynamic>)>[];
    for (final item in data) {
      final n = _normalize(item['nom'] as String);
      final s = _score(n, q, words, (item['kcal'] as num).toDouble());
      if (s > 0) scored.add((s, item));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));

    return scored.take(15).map((e) => _toModel(e.$2)).toList();
  }

  static int _score(String n, String q, List<String> words, double kcal) {
    int score;
    if (n == q || n.startsWith('$q,')) {
      score = 600; // Aliment exact : "Banane, chair sans peau..."
    } else if (n.startsWith('$q ')) {
      score = 490; // Sous-type : "Banane plantain..."
    } else if (n.startsWith(q)) {
      score = 400;
    } else if (words.every((w) => n.contains(w))) {
      score = 200 + (words.isNotEmpty && n.startsWith(words.first) ? 50 : 0);
    } else {
      final mc = words.where((w) => n.contains(w)).length;
      if (mc == 0) return 0;
      score = mc * 30 + (words.isNotEmpty && n.startsWith(words.first) ? 50 : 0);
    }
    if (kcal > 0) score += 25; // Privilégier les aliments avec données
    score -= n.length ~/ 8;    // Pénaliser les noms trop longs
    return score;
  }

  static FoodModel _toModel(Map<String, dynamic> item) {
    return FoodModel(
      id: item['id'] as String,
      nom: item['nom'] as String,
      caloriesPer100g: (item['kcal'] as num).toDouble(),
      proteinPer100g: (item['prot'] as num).toDouble(),
      carbsPer100g: (item['gluc'] as num).toDouble(),
      fatsPer100g: (item['lip'] as num).toDouble(),
      fiberPer100g: (item['fib'] as num).toDouble(),
      sugarPer100g: (item['suc'] as num).toDouble(),
      sodiumPer100g: (item['sod'] as num).toDouble(),
      source: 'ciqual',
    );
  }

  static const _accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i',
    'ô': 'o', 'ö': 'o', 'ó': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };

  static String _normalize(String s) {
    final buf = StringBuffer();
    for (final c in s.toLowerCase().split('')) {
      buf.write(_accents[c] ?? c);
    }
    return buf.toString();
  }
}
