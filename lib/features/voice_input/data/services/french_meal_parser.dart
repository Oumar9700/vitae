import '../../domain/entities/parsed_meal_item.dart';

class FrenchMealParser {
  // ── Number vocabulary ──────────────────────────────────────────────────────
  static const _numberWords = <String, double>{
    'zéro': 0.0, 'un': 1.0, 'une': 1.0, 'deux': 2.0, 'trois': 3.0,
    'quatre': 4.0, 'cinq': 5.0, 'six': 6.0, 'sept': 7.0,
    'huit': 8.0, 'neuf': 9.0, 'dix': 10.0, 'onze': 11.0, 'douze': 12.0,
    'treize': 13.0, 'quatorze': 14.0, 'quinze': 15.0, 'seize': 16.0,
    'vingt': 20.0, 'trente': 30.0, 'quarante': 40.0, 'cinquante': 50.0,
    'soixante': 60.0, 'cent': 100.0,
    'demi': 0.5, 'demie': 0.5,
    'quelques': 3.0, 'plusieurs': 3.0,
  };

  // ── Container units → (normalized label, grams per unit) ──────────────────
  static const _units = <String, (String, double)>{
    'verre': ('verre', 200.0), 'verres': ('verre', 200.0),
    'bol': ('bol', 250.0), 'bols': ('bol', 250.0),
    'assiette': ('portion', 200.0), 'assiettes': ('portion', 200.0),
    'assiettée': ('portion', 200.0), 'assiettées': ('portion', 200.0),
    'plat': ('portion', 300.0), 'plats': ('portion', 300.0),
    'tranche': ('tranche', 35.0), 'tranches': ('tranche', 35.0),
    'tasse': ('tasse', 240.0), 'tasses': ('tasse', 240.0),
    'cuillère': ('cuillère à soupe', 15.0), 'cuilleres': ('cuillère à soupe', 15.0),
    'cuillere': ('cuillère à soupe', 15.0), 'cuillères': ('cuillère à soupe', 15.0),
    'cs': ('cuillère à soupe', 15.0),   // abréviation orale
    'cc': ('cuillère à café', 5.0),      // abréviation orale
    'portion': ('portion', 150.0), 'portions': ('portion', 150.0),
    'part': ('portion', 150.0), 'parts': ('portion', 150.0),
    'poignée': ('g', 30.0), 'poignées': ('g', 30.0), 'poignee': ('g', 30.0),
    'morceau': ('g', 80.0), 'morceaux': ('g', 80.0),
    'pot': ('g', 125.0), 'pots': ('g', 125.0),
    'sachet': ('g', 30.0), 'sachets': ('g', 30.0),
    'boîte': ('g', 400.0), 'boite': ('g', 400.0), 'boîtes': ('g', 400.0),
    'canette': ('ml', 330.0), 'canettes': ('ml', 330.0),
    'bouteille': ('ml', 500.0), 'bouteilles': ('ml', 500.0),
    'ml': ('ml', 1.0), 'cl': ('ml', 10.0), 'dl': ('ml', 100.0),
    'litre': ('ml', 1000.0), 'litres': ('ml', 1000.0),
    'kg': ('g', 1000.0), 'kilogramme': ('g', 1000.0), 'kilogrammes': ('g', 1000.0),
  };

  // ── Food-specific portion sizes (grams per typical serving) ───────────────
  static const _foodPortions = <String, double>{
    // Protéines animales
    'oeuf': 55.0, 'œuf': 55.0,
    'poulet': 120.0, 'dinde': 120.0, 'porc': 120.0,
    'boeuf': 120.0, 'bœuf': 120.0, 'agneau': 120.0, 'veau': 120.0,
    'poisson': 130.0, 'saumon': 130.0, 'thon': 90.0, 'cabillaud': 130.0,
    'crevette': 80.0, 'jambon': 30.0, 'bacon': 20.0, 'saucisse': 60.0,
    'merguez': 60.0, 'steak': 150.0,
    // Produits laitiers
    'yaourt': 125.0, 'yogourt': 125.0,
    'fromage': 30.0, 'camembert': 30.0, 'brie': 30.0, 'emmental': 20.0,
    'parmesan': 10.0, 'mozzarella': 30.0, 'beurre': 10.0,
    // Fruits
    'pomme': 150.0, 'poire': 150.0, 'orange': 150.0, 'banane': 120.0,
    'kiwi': 80.0, 'abricot': 40.0, 'peche': 130.0, 'pêche': 130.0,
    'prune': 45.0, 'fraise': 10.0, 'framboise': 5.0, 'raisin': 5.0,
    'cerise': 8.0, 'mangue': 200.0, 'ananas': 80.0, 'melon': 200.0,
    'pastèque': 250.0, 'pasteque': 250.0, 'clémentine': 60.0,
    'clementine': 60.0, 'mandarine': 70.0,
    // Légumes
    'carotte': 80.0, 'tomate': 120.0, 'concombre': 60.0, 'poivron': 150.0,
    'courgette': 150.0, 'aubergine': 200.0, 'brocoli': 100.0, 'chou': 150.0,
    'epinard': 100.0, 'épinard': 100.0, 'salade': 100.0, 'avocat': 100.0,
    'oignon': 80.0, 'ail': 5.0, 'champignon': 80.0,
    // Féculents / boulangerie
    'pain': 35.0, 'baguette': 60.0, 'croissant': 60.0, 'brioche': 40.0,
    'biscuit': 10.0, 'gateau': 80.0, 'gâteau': 80.0, 'madeleine': 30.0,
    'crepe': 50.0, 'crêpe': 50.0,
    // Boissons (verre de…)
    'cafe': 250.0, 'café': 250.0, 'the': 250.0, 'thé': 250.0,
    'lait': 200.0, 'jus': 200.0, 'biere': 330.0, 'bière': 330.0,
    'vin': 120.0, 'eau': 250.0, 'soda': 250.0,
    // Oléagineux
    'noix': 4.0, 'amande': 2.0, 'noisette': 1.5, 'cajou': 2.0,
    'pistache': 1.0, 'noix de cajou': 2.0,
    // Divers
    'chocolat': 30.0, 'confiture': 20.0, 'miel': 15.0,
  };

  // ── Mots invariables au pluriel ────────────────────────────────────────────
  static const _invariables = <String>{
    'riz', 'fois', 'noix', 'brebis', 'souris', 'bas', 'sas',
    'semoule', 'quinoa', 'café', 'thé', 'lait', 'eau', 'miel',
    'persil', 'basilic', 'ail', 'sel', 'poivre', 'beurre', 'huile',
    'sucre', 'farine', 'ketchup', 'mayo',
  };

  static const _preambles = [
    "j'ai mangé", "j'ai bu", "j'ai pris", "j'ai avalé", "j'ai consommé",
    "j'ai eu", "j'ai pris", "mangé", "bu", "pris", "avalé", "consommé",
    "pour le déjeuner", "pour le dîner", "au petit déjeuner",
  ];

  static final _rGrams = RegExp(
    r'^(\d+(?:[.,]\d+)?)\s*g(?:rammes?)?\s+(?:de\s+)?(.+)$',
    caseSensitive: false,
  );

  // ── Entrée principale ──────────────────────────────────────────────────────

  static List<ParsedMealItem> parse(String text) {
    var s = _normalize(text);
    s = _removePreamble(s);
    s = _expandCompoundNumbers(s);

    return _smartSplit(s)
        .map((seg) => seg.trim())
        .where((seg) => seg.length > 1)
        .map(_parseSegment)
        .whereType<ParsedMealItem>()
        .where((item) => item.foodName.length > 1)
        .toList();
  }

  // ── Normalisation ──────────────────────────────────────────────────────────

  static String _normalize(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(''', "'")
      .replaceAll(''', "'")
      .replaceAll(RegExp(r'\s+'), ' ');

  static String _removePreamble(String s) {
    for (final p in _preambles) {
      if (s.startsWith('$p ') || s == p) {
        return s.substring(p.length).trimLeft();
      }
    }
    return s;
  }

  // Transforme "une douzaine de X" → "12 X", "une dizaine de X" → "10 X", etc.
  static String _expandCompoundNumbers(String s) => s
      .replaceAll(RegExp(r'une? douzaine de\s+'), '12 ')
      .replaceAll(RegExp(r'une? dizaine de\s+'), '10 ')
      .replaceAll(RegExp(r'une? vingtaine de\s+'), '20 ')
      .replaceAll(RegExp(r'une? trentaine de\s+'), '30 ')
      .replaceAll(RegExp(r'quelques\s+'), '3 ')
      .replaceAll(RegExp(r'plusieurs\s+'), '3 ');

  // ── Découpage intelligent ──────────────────────────────────────────────────

  static List<String> _smartSplit(String text) {
    // Séparateurs non-ambigus
    final chunks = text
        .replaceAll(RegExp(r',\s*'), '|||')
        .replaceAll(RegExp(r';\s*'), '|||')
        .replaceAll(RegExp(r'\s+et\s+'), '|||')
        .replaceAll(RegExp(r'\s+plus\s+'), '|||')
        .replaceAll(RegExp(r'\s+ainsi que\s+'), '|||')
        .split('|||');

    // "avec" : ne sépare que si ce qui précède contient une quantité
    return chunks
        .expand(_maybeSplitOnAvec)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static Iterable<String> _maybeSplitOnAvec(String seg) {
    final idx = seg.indexOf(' avec ');
    if (idx == -1) return [seg];

    final before = seg.substring(0, idx).trim();
    final after = seg.substring(idx + 6).trim();

    // Sépare uniquement si la partie gauche commence par un nombre
    if (_startsWithQuantity(before)) {
      return [before, ..._maybeSplitOnAvec(after)];
    }
    return [seg]; // "salade avec thon" reste groupé
  }

  static bool _startsWithQuantity(String s) {
    if (s.isEmpty) return false;
    final first = s.split(' ').first;
    return RegExp(r'^\d').hasMatch(first) || _numberWords.containsKey(first);
  }

  // ── Parsing d'un segment ───────────────────────────────────────────────────

  static ParsedMealItem? _parseSegment(String seg) {
    seg = seg
        .replaceAll(RegExp(r"^(?:du|de la|de l'|des|un peu de|un peu d'|un peu|de|d')\s+"), '')
        .trim();
    if (seg.isEmpty) return null;

    // Détecte "demi" en préfixe : "demi verre", "demi-pomme", "demie tasse"
    double demiMult = 1.0;
    if (seg.startsWith('demi-') || seg.startsWith('demi ') || seg.startsWith('demie ')) {
      demiMult = 0.5;
      seg = seg.replaceFirst(RegExp(r'^demie?[-\s]+'), '').trim();
    }

    // ── Pattern 1 : "150g de riz" ─────────────────────────────────────────
    final mGrams = _rGrams.firstMatch(seg);
    if (mGrams != null) {
      final qty = _parseNum(mGrams.group(1)!) * demiMult;
      return _make(_cleanFood(mGrams.group(2)!), qty, 'g', qty.clamp(1.0, 2000.0));
    }

    final tokens = seg.split(RegExp(r'\s+'));
    if (tokens.isEmpty) return null;

    // ── Patterns 2 & 3 : [nombre] ([demi])? [unité] (de)? [aliment] ──────
    final p = _tryUnitPattern(tokens, demiMult);
    if (p != null) return p;

    // ── Pattern 4 : [nombre] [aliment] — ex. "2 œufs", "une pomme" ────────
    if (tokens.length >= 2) {
      final numVal = _parseNum(tokens[0]);
      if (numVal > 0) {
        final food = _cleanFood(tokens.sublist(1).join(' '));
        if (food.isNotEmpty) {
          final portionG = _portionForFood(food);
          return _make(food, numVal * demiMult, 'portion',
              (numVal * demiMult * portionG).clamp(5.0, 1000.0));
        }
      }
    }

    // ── Pattern 5 : aliment seul — ex. "yaourt", "pain complet" ──────────
    final food = _cleanFood(seg);
    if (food.length > 1) {
      final portionG = _portionForFood(food);
      return _make(food, 1.0 * demiMult, 'portion',
          (portionG * demiMult).clamp(5.0, 500.0));
    }

    return null;
  }

  static ParsedMealItem? _tryUnitPattern(List<String> tokens, double demiMult) {
    if (tokens.length < 2) return null;

    // Essaie [tokens[0]] comme nombre (digit ou mot)
    final numVal = _parseNum(tokens[0]);
    if (numVal <= 0) return null;

    // Cherche éventuellement "demi" après le nombre : "2 demi verres"
    var unitIdx = 1;
    var mult = demiMult;
    if (tokens.length >= 3 &&
        (tokens[1] == 'demi' || tokens[1] == 'demie')) {
      mult = 0.5 * demiMult;
      unitIdx = 2;
    }

    if (unitIdx >= tokens.length) return null;

    final rawUnit = tokens[unitIdx].toLowerCase();
    if (!_units.containsKey(rawUnit)) return null;

    final (normUnit, gramsPerUnit) = _units[rawUnit]!;

    // Aliment après l'unité (optionnellement précédé de "de/d'")
    final nextIdx = unitIdx + 1;
    final foodStart = nextIdx < tokens.length &&
            (tokens[nextIdx] == 'de' || tokens[nextIdx] == "d'")
        ? nextIdx + 1
        : nextIdx;

    final food = foodStart < tokens.length
        ? _cleanFood(tokens.sublist(foodStart).join(' '))
        : '';

    if (food.isEmpty && normUnit != 'g' && normUnit != 'ml') return null;

    final totalGrams = numVal * mult * gramsPerUnit;
    final foodName = food.isNotEmpty ? food : rawUnit;
    return _make(foodName, numVal * mult, normUnit, totalGrams.clamp(1.0, 2000.0));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static ParsedMealItem _make(String food, double qty, String unit, double grams) {
    return ParsedMealItem(
      foodName: food.trim(),
      quantity: qty,
      unit: unit,
      estimatedGrams: grams,
    );
  }

  static double _parseNum(String s) {
    s = s.replaceAll(',', '.');
    return double.tryParse(s) ?? _numberWords[s.toLowerCase()] ?? 0.0;
  }

  /// Cherche la taille de portion typique pour un aliment.
  /// Essaie : nom exact → singulier → correspondance partielle.
  static double _portionForFood(String food) {
    if (_foodPortions.containsKey(food)) return _foodPortions[food]!;
    final singular = _singularize(food);
    if (_foodPortions.containsKey(singular)) return _foodPortions[singular]!;
    // Correspondance partielle : "pomme rouge" → "pomme"
    for (final key in _foodPortions.keys) {
      if (food.contains(key) || key.contains(food)) return _foodPortions[key]!;
    }
    return 100.0;
  }

  static String _singularize(String s) {
    if (_invariables.contains(s)) return s;
    if (s.endsWith('aux') && s.length > 4) return '${s.substring(0, s.length - 3)}al';
    if (s.endsWith('s') && s.length > 3) return s.substring(0, s.length - 1);
    return s;
  }

  static String _cleanFood(String s) {
    s = s
        .replaceAll(
          RegExp(
            r'\b(?:brouill[eé]e?s?|grill[eé]e?s?|cuit(?:e)?s?|frit(?:e)?s?'
            r'|r[oô]ti(?:e)?s?|vapeur|chaud(?:e)?s?|froid(?:e)?s?'
            r'|nature|entier(?:e)?s?|frais|fraîche?s?|poché(?:e)?s?'
            r'|pané(?:e)?s?|fumé(?:e)?s?|séché(?:e)?s?|mariné(?:e)?s?)\b',
          ),
          '',
        )
        .replaceAll(
          RegExp(r"\b(?:du|de la|de l'|des|le|la|les|un|une|au|aux)\b"),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return _singularize(s);
  }
}
