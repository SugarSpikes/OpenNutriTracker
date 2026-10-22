import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:opennutritracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_const.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_food_nutriment_dto.dart';
import 'package:opennutritracker/features/add_meal/data/dto/off/off_product_nutriments_dto.dart';
import 'package:opennutritracker/features/add_meal/data/dto/sp/sp_food_dto.dart';

class MealNutrimentsEntity extends Equatable {
  final double? energyKcal100;

  final double? carbohydrates100;
  final double? fat100;
  final double? proteins100;
  final double? sugars100;
  final double? saturatedFat100;
  final double? fiber100;

  // #237: Extended lipid profile
  final double? monounsaturatedFat100;
  final double? polyunsaturatedFat100;
  final double? transFat100;
  final double? cholesterol100;

  // #237: Minerals (mg per 100g)
  final double? sodium100;
  final double? potassium100;
  final double? magnesium100;
  final double? calcium100;
  final double? iron100;
  final double? zinc100;
  final double? phosphorus100;

  // #237: Vitamins
  final double? vitaminA100; // µg RAE
  final double? vitaminC100; // mg
  final double? vitaminD100; // µg
  final double? vitaminB6100; // mg
  final double? vitaminB12100; // µg
  final double? niacin100; // mg (B3)

  /// Additional nutrients not represented by dedicated fields above.
  ///
  /// Values are normalized per 100 g. Units must be defined by nutrient ID
  /// by the source or code that interprets this map.
  final Map<String, double> additionalNutrientsPer100;

  double? get energyPerUnit => _getValuePerUnit(energyKcal100);

  double? get carbohydratesPerUnit => _getValuePerUnit(carbohydrates100);

  double? get fatPerUnit => _getValuePerUnit(fat100);

  double? get proteinsPerUnit => _getValuePerUnit(proteins100);

  /// Returns true when at least one extended nutrient field has a value.
  bool get hasMicronutrientData =>
      monounsaturatedFat100 != null ||
      polyunsaturatedFat100 != null ||
      transFat100 != null ||
      cholesterol100 != null ||
      sodium100 != null ||
      potassium100 != null ||
      magnesium100 != null ||
      calcium100 != null ||
      iron100 != null ||
      zinc100 != null ||
      phosphorus100 != null ||
      vitaminA100 != null ||
      vitaminC100 != null ||
      vitaminD100 != null ||
      vitaminB6100 != null ||
      vitaminB12100 != null ||
      niacin100 != null ||
      additionalNutrientsPer100.isNotEmpty;

  const MealNutrimentsEntity({
    required this.energyKcal100,
    required this.carbohydrates100,
    required this.fat100,
    required this.proteins100,
    required this.sugars100,
    required this.saturatedFat100,
    required this.fiber100,
    this.monounsaturatedFat100,
    this.polyunsaturatedFat100,
    this.transFat100,
    this.cholesterol100,
    this.sodium100,
    this.potassium100,
    this.magnesium100,
    this.calcium100,
    this.iron100,
    this.zinc100,
    this.phosphorus100,
    this.vitaminA100,
    this.vitaminC100,
    this.vitaminD100,
    this.vitaminB6100,
    this.vitaminB12100,
    this.niacin100,
    this.additionalNutrientsPer100 = const {},
  });

  factory MealNutrimentsEntity.empty() => const MealNutrimentsEntity(
        energyKcal100: null,
        carbohydrates100: null,
        fat100: null,
        proteins100: null,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
      );

  factory MealNutrimentsEntity.fromMealNutrimentsDBO(
    MealNutrimentsDBO nutriments,
  ) {
    return MealNutrimentsEntity(
      energyKcal100: nutriments.energyKcal100,
      carbohydrates100: nutriments.carbohydrates100,
      fat100: nutriments.fat100,
      proteins100: nutriments.proteins100,
      sugars100: nutriments.sugars100,
      saturatedFat100: nutriments.saturatedFat100,
      fiber100: nutriments.fiber100,
      monounsaturatedFat100: nutriments.monounsaturatedFat100,
      polyunsaturatedFat100: nutriments.polyunsaturatedFat100,
      transFat100: nutriments.transFat100,
      cholesterol100: nutriments.cholesterol100,
      sodium100: nutriments.sodium100,
      potassium100: nutriments.potassium100,
      magnesium100: nutriments.magnesium100,
      calcium100: nutriments.calcium100,
      iron100: nutriments.iron100,
      zinc100: nutriments.zinc100,
      phosphorus100: nutriments.phosphorus100,
      vitaminA100: nutriments.vitaminA100,
      vitaminC100: nutriments.vitaminC100,
      vitaminD100: nutriments.vitaminD100,
      vitaminB6100: nutriments.vitaminB6100,
      vitaminB12100: nutriments.vitaminB12100,
      niacin100: nutriments.niacin100,
    );
  }

  factory MealNutrimentsEntity.fromOffNutriments(
    OFFProductNutrimentsDTO? offNutriments,
  ) {
    if (offNutriments == null) return MealNutrimentsEntity.empty();

    // OFF values can be String, int, double or null.
    // Cast to Object? before using asDoubleOrNull.
    return MealNutrimentsEntity(
      energyKcal100:
          (offNutriments.energy_kcal_100g as Object?).asDoubleOrNull(),
      carbohydrates100:
          (offNutriments.carbohydrates_100g as Object?).asDoubleOrNull(),
      fat100: (offNutriments.fat_100g as Object?).asDoubleOrNull(),
      proteins100: (offNutriments.proteins_100g as Object?).asDoubleOrNull(),
      sugars100: (offNutriments.sugars_100g as Object?).asDoubleOrNull(),
      saturatedFat100:
          (offNutriments.saturated_fat_100g as Object?).asDoubleOrNull(),
      fiber100: (offNutriments.fiber_100g as Object?).asDoubleOrNull(),

      // Extended lipid profile
      monounsaturatedFat100:
          (offNutriments.monounsaturated_fat_100g as Object?).asDoubleOrNull(),
      polyunsaturatedFat100:
          (offNutriments.polyunsaturated_fat_100g as Object?).asDoubleOrNull(),
      transFat100: (offNutriments.trans_fat_100g as Object?).asDoubleOrNull(),
      cholesterol100:
          (offNutriments.cholesterol_100g as Object?).asDoubleOrNull(),

      // Minerals
      sodium100: (offNutriments.sodium_100g as Object?).asDoubleOrNull(),
      potassium100: (offNutriments.potassium_100g as Object?).asDoubleOrNull(),
      magnesium100: (offNutriments.magnesium_100g as Object?).asDoubleOrNull(),
      calcium100: (offNutriments.calcium_100g as Object?).asDoubleOrNull(),
      iron100: (offNutriments.iron_100g as Object?).asDoubleOrNull(),
      zinc100: (offNutriments.zinc_100g as Object?).asDoubleOrNull(),
      phosphorus100:
          (offNutriments.phosphorus_100g as Object?).asDoubleOrNull(),

      // Vitamins
      vitaminA100: (offNutriments.vitamin_a_100g as Object?).asDoubleOrNull(),
      vitaminC100: (offNutriments.vitamin_c_100g as Object?).asDoubleOrNull(),
      vitaminD100: (offNutriments.vitamin_d_100g as Object?).asDoubleOrNull(),
      vitaminB6100: (offNutriments.vitamin_b6_100g as Object?).asDoubleOrNull(),
      vitaminB12100:
          (offNutriments.vitamin_b12_100g as Object?).asDoubleOrNull(),
      niacin100: (offNutriments.niacin_100g as Object?).asDoubleOrNull(),
    );
  }

  /// Nutrients from the Supabase food_summary view.
  ///
  /// The view pivots canonical per-100g nutrient rows into flat columns.
  factory MealNutrimentsEntity.fromSpFoodSummary(SpFoodDTO food) {
    return MealNutrimentsEntity(
      energyKcal100: food.energyKcal100,
      carbohydrates100: food.carbohydrates100,
      fat100: food.fat100,
      proteins100: food.proteins100,
      sugars100: food.sugars100,
      saturatedFat100: food.saturatedFat100,
      fiber100: food.fiber100,
      monounsaturatedFat100: food.monounsaturatedFat100,
      polyunsaturatedFat100: food.polyunsaturatedFat100,
      transFat100: food.transFat100,
      cholesterol100: food.cholesterol100,
      sodium100: food.sodium100,
      potassium100: food.potassium100,
      magnesium100: food.magnesium100,
      calcium100: food.calcium100,
      iron100: food.iron100,
      zinc100: food.zinc100,
      phosphorus100: food.phosphorus100,
      vitaminA100: food.vitaminA100,
      vitaminC100: food.vitaminC100,
      vitaminD100: food.vitaminD100,
      vitaminB6100: food.vitaminB6100,
      vitaminB12100: food.vitaminB12100,
      niacin100: food.niacin100,
    );
  }

  factory MealNutrimentsEntity.fromFDCNutriments(
    List<FDCFoodNutrimentDTO> fdcNutriment,
  ) {
    double? fdcAmount(int nutrientId) => fdcNutriment
        .firstWhereOrNull((nutriment) => nutriment.nutrientId == nutrientId)
        ?.amount;

    // Prefer the most precise Atwater energy value, then fall back.
    final energyTotal = fdcAmount(FDCConst.fdcKcalAtwaterSpecificId) ??
        fdcAmount(FDCConst.fdcKcalAtwaterGeneralId) ??
        fdcAmount(FDCConst.fdcTotalKcalId);

    return MealNutrimentsEntity(
      energyKcal100: energyTotal,
      carbohydrates100: fdcAmount(FDCConst.fdcTotalCarbsId),
      fat100: fdcAmount(FDCConst.fdcTotalFatId),
      proteins100: fdcAmount(FDCConst.fdcTotalProteinsId),
      sugars100: fdcAmount(FDCConst.fdcTotalSugarId),
      saturatedFat100: fdcAmount(FDCConst.fdcTotalSaturatedFatId),
      fiber100: fdcAmount(FDCConst.fdcTotalDietaryFiberId),

      // Extended lipid profile
      monounsaturatedFat100: fdcAmount(FDCConst.fdcMonounsaturatedFatId),
      polyunsaturatedFat100: fdcAmount(FDCConst.fdcPolyunsaturatedFatId),
      transFat100: fdcAmount(FDCConst.fdcTransFatId),
      cholesterol100: fdcAmount(FDCConst.fdcCholesterolId),

      // Minerals
      sodium100: fdcAmount(FDCConst.fdcSodiumId),
      potassium100: fdcAmount(FDCConst.fdcPotassiumId),
      magnesium100: fdcAmount(FDCConst.fdcMagnesiumId),
      calcium100: fdcAmount(FDCConst.fdcCalciumId),
      iron100: fdcAmount(FDCConst.fdcIronId),
      zinc100: fdcAmount(FDCConst.fdcZincId),
      phosphorus100: fdcAmount(FDCConst.fdcPhosphorusId),

      // Vitamins
      vitaminA100: fdcAmount(FDCConst.fdcVitaminAId),
      vitaminC100: fdcAmount(FDCConst.fdcVitaminCId),
      vitaminD100: fdcAmount(FDCConst.fdcVitaminDId),
      vitaminB6100: fdcAmount(FDCConst.fdcVitaminB6Id),
      vitaminB12100: fdcAmount(FDCConst.fdcVitaminB12Id),
      niacin100: fdcAmount(FDCConst.fdcNiacinId),
    );
  }

  static double? _getValuePerUnit(double? valuePer100) {
    if (valuePer100 != null) {
      return valuePer100 / 100;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        energyKcal100,
        carbohydrates100,
        fat100,
        proteins100,
        sugars100,
        saturatedFat100,
        fiber100,
        monounsaturatedFat100,
        polyunsaturatedFat100,
        transFat100,
        cholesterol100,
        sodium100,
        potassium100,
        magnesium100,
        calcium100,
        iron100,
        zinc100,
        phosphorus100,
        vitaminA100,
        vitaminC100,
        vitaminD100,
        vitaminB6100,
        vitaminB12100,
        niacin100,
        additionalNutrientsPer100,
      ];
}

/// Outcome of running physical-plausibility checks against a nutrient entity.
class NutrimentsValidationResult {
  final bool isConsistent;
  final String? failureReason;

  const NutrimentsValidationResult.ok()
      : isConsistent = true,
        failureReason = null;

  const NutrimentsValidationResult.failed(this.failureReason)
      : isConsistent = false;
}

/// Tolerance applied to weight-summation and subset comparisons.
const double _nutrimentsValidationToleranceG = 1.0;

/// Returns true when [nutriments] passes the three physical-plausibility rules:
///
/// 1. Sugars do not exceed carbohydrates.
/// 2. Saturated fat does not exceed total fat.
/// 3. Carbohydrates, fat and protein do not sum to more than 100 g.
///
/// Null values skip the corresponding comparison.
bool isNutrimentsConsistent(MealNutrimentsEntity nutriments) =>
    validateNutriments(nutriments).isConsistent;

/// Full validation result, including the first failing rule.
NutrimentsValidationResult validateNutriments(
  MealNutrimentsEntity nutriments,
) {
  final sugars = nutriments.sugars100;
  final carbs = nutriments.carbohydrates100;

  if (sugars != null &&
      carbs != null &&
      sugars > carbs + _nutrimentsValidationToleranceG) {
    return const NutrimentsValidationResult.failed('sugars_exceed_carbs');
  }

  final satFat = nutriments.saturatedFat100;
  final fat = nutriments.fat100;

  if (satFat != null &&
      fat != null &&
      satFat > fat + _nutrimentsValidationToleranceG) {
    return const NutrimentsValidationResult.failed(
      'saturated_fat_exceeds_total_fat',
    );
  }

  // Fibre is excluded because it is generally included in carbohydrates.
  final protein = nutriments.proteins100;
  final macroSum = (carbs ?? 0) + (fat ?? 0) + (protein ?? 0);

  if (macroSum > 100 + _nutrimentsValidationToleranceG) {
    return const NutrimentsValidationResult.failed('macros_exceed_100g');
  }

  return const NutrimentsValidationResult.ok();
}

/// Maximum relative gap between declared and Atwater-computed energy.
const double atwaterEnergyTolerance = 0.25;

/// Relative difference between declared energy and energy calculated using
/// the general Atwater factors: carbohydrates 4, protein 4, fat 9 kcal/g.
///
/// Returns null when there is insufficient data to make the comparison.
double? atwaterEnergyRelativeError(MealNutrimentsEntity nutriments) {
  final energy = nutriments.energyKcal100;
  if (energy == null || energy <= 0) return null;

  final carbs = nutriments.carbohydrates100;
  final fat = nutriments.fat100;
  final protein = nutriments.proteins100;

  if (carbs == null && fat == null && protein == null) return null;

  final computed = 4 * (carbs ?? 0) + 4 * (protein ?? 0) + 9 * (fat ?? 0);

  return (energy - computed).abs() / energy;
}

/// True when declared energy is coherent with the macros or cannot be judged.
bool isAtwaterConsistent(MealNutrimentsEntity nutriments) {
  final error = atwaterEnergyRelativeError(nutriments);
  return error == null || error <= atwaterEnergyTolerance;
}