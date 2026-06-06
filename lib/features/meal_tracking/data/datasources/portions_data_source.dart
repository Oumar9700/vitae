import '../../domain/entities/food_portion.dart';

/// Données de portions standardisées pour les aliments courants français.
/// Priorité CIQUAL : le nom normalisé est comparé au nom de l'aliment.
class PortionsService {
  static List<FoodPortion> getPortions(String foodName) {
    final n = _normalize(foodName);
    for (final entry in _portionsMap.entries) {
      if (n.contains(entry.key)) return entry.value;
    }
    return [];
  }

  static PortionSizes getCommonSizes(String foodName) {
    final n = _normalize(foodName);
    for (final entry in _sizesMap.entries) {
      if (n.contains(entry.key)) return entry.value;
    }
    return const PortionSizes(small: 50, medium: 100, large: 200);
  }

  static String _normalize(String s) {
    const accents = {
      'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
      'î': 'i', 'ï': 'i',
      'ô': 'o', 'ö': 'o',
      'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c',
    };
    final buf = StringBuffer();
    for (final c in s.toLowerCase().split('')) {
      buf.write(accents[c] ?? c);
    }
    return buf.toString();
  }

  static const Map<String, List<FoodPortion>> _portionsMap = {
    'riz': [
      FoodPortion(label: 'Petite portion', grams: 80, description: 'Accompagnement léger — Ø assiette entrebaillée'),
      FoodPortion(label: 'Portion normale', grams: 150, description: 'Assiette standard — environ 1 demi-bol'),
      FoodPortion(label: 'Grande portion', grams: 250, description: 'Plat complet — bol plein'),
    ],
    'pate': [
      FoodPortion(label: 'Petite portion', grams: 80, description: 'Accompagnement léger'),
      FoodPortion(label: 'Portion normale', grams: 150, description: 'Assiette standard'),
      FoodPortion(label: 'Grande portion', grams: 250, description: 'Plat copieux'),
    ],
    'pain': [
      FoodPortion(label: '1 tranche fine', grams: 25, description: 'Grille-pain'),
      FoodPortion(label: '2 tranches', grams: 60, description: 'Sandwich'),
      FoodPortion(label: '1/4 baguette', grams: 65, description: 'Accompagnement'),
    ],
    'baguette': [
      FoodPortion(label: '1/4 de baguette', grams: 65, description: 'Accompagnement'),
      FoodPortion(label: '1/2 baguette', grams: 130, description: 'Repas'),
      FoodPortion(label: 'Baguette entière', grams: 260, description: 'Partage'),
    ],
    'poulet': [
      FoodPortion(label: 'Petit filet', grams: 100, description: '1 filet mince'),
      FoodPortion(label: 'Filet standard', grams: 150, description: '1 filet normal'),
      FoodPortion(label: 'Grosse cuisse', grams: 200, description: 'Cuisse entière'),
    ],
    'boeuf': [
      FoodPortion(label: 'Steak léger', grams: 100, description: 'Steak mince'),
      FoodPortion(label: 'Steak standard', grams: 150, description: 'Portion normale'),
      FoodPortion(label: 'Grande pièce', grams: 250, description: 'Pièce de bœuf'),
    ],
    'saumon': [
      FoodPortion(label: 'Petit filet', grams: 100, description: '1 filet mince'),
      FoodPortion(label: 'Filet standard', grams: 150, description: 'Portion normale'),
      FoodPortion(label: 'Grand filet', grams: 200, description: 'Grosse portion'),
    ],
    'thon': [
      FoodPortion(label: '1/2 boîte', grams: 75, description: 'Boîte standard'),
      FoodPortion(label: '1 boîte', grams: 150, description: 'Boîte entière'),
      FoodPortion(label: 'Grande portion', grams: 200, description: 'Steak de thon'),
    ],
    'orange': [
      FoodPortion(label: 'Petite orange', grams: 130, description: '~Ø 6 cm'),
      FoodPortion(label: 'Orange moyenne', grams: 170, description: '~Ø 7 cm'),
      FoodPortion(label: 'Grande orange', grams: 220, description: '~Ø 8 cm'),
    ],
    'pomme': [
      FoodPortion(label: 'Petite pomme', grams: 100, description: '~Ø 6 cm'),
      FoodPortion(label: 'Pomme moyenne', grams: 150, description: '~Ø 7 cm'),
      FoodPortion(label: 'Grande pomme', grams: 200, description: '~Ø 8 cm'),
    ],
    'banane': [
      FoodPortion(label: 'Petite banane', grams: 80, description: '~15 cm'),
      FoodPortion(label: 'Banane normale', grams: 120, description: '~20 cm'),
      FoodPortion(label: 'Grande banane', grams: 160, description: '~25 cm'),
    ],
    'oeuf': [
      FoodPortion(label: '1 œuf', grams: 55, description: 'Œuf moyen'),
      FoodPortion(label: '2 œufs', grams: 110, description: 'Omelette standard'),
      FoodPortion(label: '3 œufs', grams: 165, description: 'Brouillés copieux'),
    ],
    'lait': [
      FoodPortion(label: 'Petit verre', grams: 150, description: '15 cl'),
      FoodPortion(label: 'Grand verre', grams: 250, description: '25 cl'),
      FoodPortion(label: 'Bol', grams: 300, description: '30 cl — café-crème'),
    ],
    'yaourt': [
      FoodPortion(label: '1 pot nature', grams: 125, description: 'Pot standard (125 g)'),
      FoodPortion(label: '1 pot grec', grams: 150, description: 'Pot grec standard'),
      FoodPortion(label: '2 pots', grams: 250, description: 'Grande collation'),
    ],
    'fromage': [
      FoodPortion(label: 'Fine tranche', grams: 20, description: 'Sur tartine'),
      FoodPortion(label: 'Tranche normale', grams: 30, description: 'Portion standard'),
      FoodPortion(label: 'Portion généreuse', grams: 50, description: 'Plateau'),
    ],
    'legume': [
      FoodPortion(label: 'Accompagnement', grams: 80, description: 'Légume de côté'),
      FoodPortion(label: 'Portion normale', grams: 150, description: 'Part équilibrée'),
      FoodPortion(label: 'Grande portion', grams: 250, description: 'Plat de légumes'),
    ],
    'salade': [
      FoodPortion(label: 'Petite entrée', grams: 50, description: 'Quelques feuilles'),
      FoodPortion(label: 'Entrée normale', grams: 100, description: 'Bol d\'entrée'),
      FoodPortion(label: 'Plat complet', grams: 200, description: 'Salade repas'),
    ],
    'soupe': [
      FoodPortion(label: 'Petit bol', grams: 200, description: 'Entrée légère'),
      FoodPortion(label: 'Bol normal', grams: 300, description: 'Portion standard'),
      FoodPortion(label: 'Grand bol', grams: 400, description: 'Repas complet'),
    ],
    'cereale': [
      FoodPortion(label: 'Petite portion', grams: 30, description: 'Bol léger'),
      FoodPortion(label: 'Portion normale', grams: 50, description: 'Bol standard'),
      FoodPortion(label: 'Grande portion', grams: 80, description: 'Grand bol'),
    ],
    'avoine': [
      FoodPortion(label: 'Petite portion', grams: 40, description: 'Bol léger'),
      FoodPortion(label: 'Portion normale', grams: 70, description: 'Bol standard'),
      FoodPortion(label: 'Grande portion', grams: 100, description: 'Grand bol'),
    ],
    'chocolat': [
      FoodPortion(label: '1 carré', grams: 10, description: '1 carré de tablette'),
      FoodPortion(label: '3 carrés', grams: 30, description: 'Petite collation'),
      FoodPortion(label: 'Demi-tablette', grams: 50, description: 'Tablette 100 g'),
    ],
    'beurre': [
      FoodPortion(label: 'Fine noisette', grams: 5, description: 'Tartine légère'),
      FoodPortion(label: 'Noisette normale', grams: 10, description: 'Tartine standard'),
      FoodPortion(label: 'Cuillère à soupe', grams: 15, description: 'Cuisine'),
    ],
    'huile': [
      FoodPortion(label: '1 c. à café', grams: 5, description: 'Assaisonnement'),
      FoodPortion(label: '1 c. à soupe', grams: 14, description: 'Cuisson'),
      FoodPortion(label: '2 c. à soupe', grams: 28, description: 'Friture légère'),
    ],
  };

  static const Map<String, PortionSizes> _sizesMap = {
    'riz': PortionSizes(small: 80, medium: 150, large: 250),
    'pate': PortionSizes(small: 80, medium: 150, large: 250),
    'pain': PortionSizes(small: 25, medium: 60, large: 100),
    'baguette': PortionSizes(small: 65, medium: 130, large: 260),
    'poulet': PortionSizes(small: 100, medium: 150, large: 200),
    'boeuf': PortionSizes(small: 100, medium: 150, large: 250),
    'saumon': PortionSizes(small: 100, medium: 150, large: 200),
    'thon': PortionSizes(small: 75, medium: 150, large: 200),
    'orange': PortionSizes(small: 130, medium: 170, large: 220),
    'pomme': PortionSizes(small: 100, medium: 150, large: 200),
    'banane': PortionSizes(small: 80, medium: 120, large: 160),
    'oeuf': PortionSizes(small: 55, medium: 110, large: 165),
    'lait': PortionSizes(small: 150, medium: 250, large: 300),
    'yaourt': PortionSizes(small: 80, medium: 125, large: 250),
    'fromage': PortionSizes(small: 20, medium: 30, large: 50),
    'legume': PortionSizes(small: 80, medium: 150, large: 250),
    'salade': PortionSizes(small: 50, medium: 100, large: 200),
    'soupe': PortionSizes(small: 200, medium: 300, large: 400),
    'cereale': PortionSizes(small: 30, medium: 50, large: 80),
    'avoine': PortionSizes(small: 40, medium: 70, large: 100),
    'chocolat': PortionSizes(small: 10, medium: 30, large: 50),
  };
}
