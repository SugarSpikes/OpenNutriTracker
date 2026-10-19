import 'dart:convert';

import 'package:opennutritracker/core/domain/entity/intake_entity.dart';

/// Exports diary entries to the JSON format accepted by JsonMealImporter.
///
/// Nutrient fields in the JSON represent totals for the logged portion.
/// The model stores nutrient values per 100 g/ml, so each exported total
/// is calculated as per-100 value * intake amount / 100.
///
/// Null nutrient values are retained as JSON null. This distinguishes
/// missing nutrient data from a measured value of zero.
class JsonMealExporter {
  /// Export a list of diary entries as a pretty-printed JSON array.
  static String intakesToJson(List<IntakeEntity> intakes) {
    final entries = intakes.map(_intakeToJson).toList();
    return const JsonEncoder.withIndent('  ').convert(entries);
  }

  /// Export one diary entry as a pretty-printed JSON object.
  static String intakeToJson(IntakeEntity intake) {
    return const JsonEncoder.withIndent('  ').convert(_intakeToJson(intake));
  }

  static Map<String, dynamic> _intakeToJson(IntakeEntity intake) {
    final meal = intake.meal;
    final n = meal.nutriments;
    final factor = intake.amount / 100.0;

    return <String, dynamic>{
      'name': meal.name ?? 'Unnamed food',
      'kcal': _portionTotal(n.energyKcal100, factor),
      'protein': _portionTotal(n.proteins100, factor),
      'carbs': _portionTotal(n.carbohydrates100, factor),
      'fat': _portionTotal(n.fat100, factor),
      'sugars': _portionTotal(n.sugars100, factor),
      'saturatedFat': _portionTotal(n.saturatedFat100, factor),
      'fiber': _portionTotal(n.fiber100, factor),
      'monounsaturatedFat':
          _portionTotal(n.monounsaturatedFat100, factor),
      'polyunsaturatedFat':
          _portionTotal(n.polyunsaturatedFat100, factor),
      'transFat': _portionTotal(n.transFat100, factor),
      'cholesterol': _portionTotal(n.cholesterol100, factor),
      'sodium': _portionTotal(n.sodium100, factor),
      'potassium': _portionTotal(n.potassium100, factor),
      'magnesium': _portionTotal(n.magnesium100, factor),
      'calcium': _portionTotal(n.calcium100, factor),
      'iron': _portionTotal(n.iron100, factor),
      'zinc': _portionTotal(n.zinc100, factor),
      'phosphorus': _portionTotal(n.phosphorus100, factor),
      'vitaminA': _portionTotal(n.vitaminA100, factor),
      'vitaminC': _portionTotal(n.vitaminC100, factor),
      'vitaminD': _portionTotal(n.vitaminD100, factor),
      'vitaminB6': _portionTotal(n.vitaminB6100, factor),
      'vitaminB12': _portionTotal(n.vitaminB12100, factor),
      'niacin': _portionTotal(n.niacin100, factor),
      'mealType': intake.type.name,
      'amount': intake.amount,
      'unit': intake.unit,
      'date': _dateOnly(intake.dateTime),
      if (meal.servingQuantity != null)
        'serving_size': meal.servingQuantity,
    };
  }

  static double? _portionTotal(double? per100, double factor) {
    if (per100 == null) return null;
    return per100 * factor;
  }

  static String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}