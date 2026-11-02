import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/utils/json_meal_importer.dart';

void main() {
  group('JsonMealImporter.parse', () {
    final fixedNow = DateTime(2026, 5, 13);

    test('parses a single valid object and writes one intake', () {
      const json = '{"name":"Apple","kcal":95,"protein":0.5,"carbs":25,'
          '"fat":0.3,"mealType":"snack","amount":100,"unit":"g",'
          '"date":"2026-05-13"}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.errors, isEmpty);
      expect(result.intakes, hasLength(1));
      final intake = result.intakes.single;
      expect(intake.meal.name, 'Apple');
      expect(intake.amount, 100);
      expect(intake.unit, 'g');
      expect(intake.type, IntakeTypeEntity.snack);
      expect(intake.dateTime, DateTime(2026, 5, 13));
      // Back-projection: 95 kcal in 100 g = 95 per 100 g.
      expect(intake.meal.nutriments.energyKcal100, closeTo(95, 0.001));
      expect(intake.totalKcal, closeTo(95, 0.001));
      expect(intake.totalCarbsGram, closeTo(25, 0.001));
      expect(intake.totalFatsGram, closeTo(0.3, 0.001));
      expect(intake.totalProteinsGram, closeTo(0.5, 0.001));
    });

    test('parses an array of three entries', () {
      const json = '['
          '{"name":"Oats","kcal":150,"protein":5,"carbs":27,"fat":2.5,'
          '"mealType":"breakfast","amount":40,"unit":"g"},'
          '{"name":"Banana","kcal":105,"protein":1.3,"carbs":27,"fat":0.4,'
          '"mealType":"snack","amount":120,"unit":"g"},'
          '{"name":"Chicken","kcal":165,"protein":31,"carbs":0,"fat":3.6,'
          '"mealType":"dinner","amount":100,"unit":"g"}'
          ']';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.errors, isEmpty);
      expect(result.intakes, hasLength(3));
      expect(result.intakes[0].meal.name, 'Oats');
      expect(result.intakes[0].type, IntakeTypeEntity.breakfast);
      expect(result.intakes[1].meal.name, 'Banana');
      expect(result.intakes[1].type, IntakeTypeEntity.snack);
      expect(result.intakes[2].meal.name, 'Chicken');
      expect(result.intakes[2].type, IntakeTypeEntity.dinner);
    });

    test('malformed JSON surfaces a parse error and no intakes', () {
      const json = '{"name":"Apple", "kcal":';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.intakes, isEmpty);
      expect(result.errors, hasLength(1));
      expect(result.errors.single, startsWith('Could not parse:'));
    });

    test('missing required field surfaces a per-entry error', () {
      // No "name" key.
      const json = '{"kcal":95,"protein":0.5,"carbs":25,"fat":0.3}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.intakes, isEmpty);
      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('missing required field'));
      expect(result.errors.single, contains('name'));
    });

    test('defaults: mealType snack, amount 100, unit g, date today', () {
      const json = '{"name":"Apple","kcal":52,"protein":0.3,"carbs":14,"fat":0.2}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.errors, isEmpty);
      final intake = result.intakes.single;
      expect(intake.type, IntakeTypeEntity.snack);
      expect(intake.amount, 100);
      expect(intake.unit, 'g');
      expect(intake.dateTime, DateTime(2026, 5, 13));
    });

    test('rejects an unknown mealType with a clear message', () {
      const json =
          '{"name":"Apple","kcal":52,"protein":0.3,"carbs":14,"fat":0.2,'
          '"mealType":"brunch"}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.intakes, isEmpty);
      expect(result.errors.single, contains('mealType'));
      expect(result.errors.single, contains('brunch'));
    });

    test('rejects a non-positive amount', () {
      const json = '{"name":"Apple","kcal":52,"protein":0.3,"carbs":14,'
          '"fat":0.2,"amount":0}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.intakes, isEmpty);
      expect(result.errors.single, contains('amount'));
    });

    test('rejects a malformed date string', () {
      const json = '{"name":"Apple","kcal":52,"protein":0.3,"carbs":14,'
          '"fat":0.2,"date":"yesterday"}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.intakes, isEmpty);
      expect(result.errors.single, contains('date'));
    });

    test('empty input is reported, not silently treated as zero entries', () {
      final result = JsonMealImporter.parse('   ', now: fixedNow);

      expect(result.intakes, isEmpty);
      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('empty'));
    });

    test('top-level non-object, non-array JSON is reported', () {
      final result = JsonMealImporter.parse('42', now: fixedNow);

      expect(result.intakes, isEmpty);
      expect(result.errors.single, contains('object or an array'));
    });

    test('amount > 100 back-projects nutriments to per-100[unit]', () {
      // 200 kcal at 200 g amount = 100 kcal / 100 g, doubled to land
      // back at 200 kcal for the logged entry.
      const json = '{"name":"Yoghurt","kcal":200,"protein":10,"carbs":20,'
          '"fat":8,"amount":200,"unit":"g"}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.errors, isEmpty);
      final intake = result.intakes.single;
      expect(intake.meal.nutriments.energyKcal100, closeTo(100, 0.001));
      expect(intake.totalKcal, closeTo(200, 0.001));
      expect(intake.totalProteinsGram, closeTo(10, 0.001));
    });

    test('serving_size populates servingQuantity on the saved meal', () {
      // Issue #420 / #421: a saved custom meal with serving values set
      // makes meal-detail default re-logged quantities to 1 serving.
      const json = '{"name":"Banana","kcal":89,"protein":1.1,"carbs":22.8,'
          '"fat":0.3,"amount":100,"unit":"g","serving_size":118}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.errors, isEmpty);
      final meal = result.intakes.single.meal;
      expect(meal.servingQuantity, 118);
      expect(meal.servingSize, '118 g');
      expect(meal.hasServingValues, isTrue);
    });

    test('serving_size omitted leaves servingQuantity null', () {
      const json = '{"name":"Apple","kcal":52,"protein":0.3,"carbs":14,'
          '"fat":0.2}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.errors, isEmpty);
      expect(result.intakes.single.meal.servingQuantity, isNull);
    });

    test('non-positive serving_size is rejected', () {
      const json = '{"name":"Apple","kcal":52,"protein":0.3,"carbs":14,'
          '"fat":0.2,"serving_size":0}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.intakes, isEmpty);
      expect(result.errors.single, contains('serving_size'));
    });

    test('decimal serving_size like 62.5 is preserved', () {
      const json = '{"name":"Protein Bar","kcal":400,"protein":20,"carbs":35,'
          '"fat":15,"serving_size":62.5}';

      final result = JsonMealImporter.parse(json, now: fixedNow);

      expect(result.errors, isEmpty);
      final meal = result.intakes.single.meal;
      expect(meal.servingQuantity, 62.5);
      expect(meal.servingSize, '62.5 g');
    });
  });

  group('JsonMealImporter.sampleJson', () {
    test('parses cleanly with no errors and produces real intakes', () {
      final result = JsonMealImporter.parse(
        JsonMealImporter.sampleJson(),
        now: DateTime(2026, 5, 13),
      );
      expect(result.errors, isEmpty,
          reason: 'the bundled sample must always be parseable');
      expect(result.intakes, isNotEmpty);
      // Each entry's stored MealEntity should at least have a name.
      for (final intake in result.intakes) {
        expect(intake.meal.name, isNotNull);
        expect(intake.meal.name, isNotEmpty);
      }
    });
  });


  test('imports all supported optional nutrients', () {
  const json = '''
  {
    "name": "Test food",
    "kcal": 100,
    "protein": 5,
    "carbs": 10,
    "fat": 4,
    "sugars": 3,
    "saturatedFat": 2,
    "fiber": 1,
    "monounsaturatedFat": 1.5,
    "polyunsaturatedFat": 0.5,
    "transFat": 0.1,
    "cholesterol": 10,
    "sodium": 20,
    "potassium": 30,
    "magnesium": 40,
    "calcium": 50,
    "iron": 0.6,
    "zinc": 0.7,
    "phosphorus": 60,
    "vitaminA": 70,
    "vitaminC": 8,
    "vitaminD": 2,
    "vitaminB6": 0.4,
    "vitaminB12": 1.2,
    "niacin": 1.8,
    "amount": 50,
    "unit": "g",
    "mealType": "lunch",
    "date": "2026-05-13"
  }
  ''';

  final result = JsonMealImporter.parse(
    json,
    now: DateTime(2026, 5, 13),
  );

  expect(result.errors, isEmpty);
  expect(result.intakes, hasLength(1));

  final nutriments = result.intakes.single.meal.nutriments;

  // The supplied values are totals for 50 g. The stored values
  // should therefore be twice the supplied values per 100 g.
  expect(nutriments.energyKcal100, closeTo(200, 0.001));
  expect(nutriments.proteins100, closeTo(10, 0.001));
  expect(nutriments.carbohydrates100, closeTo(20, 0.001));
  expect(nutriments.fat100, closeTo(8, 0.001));

  expect(nutriments.sugars100, closeTo(6, 0.001));
  expect(nutriments.saturatedFat100, closeTo(4, 0.001));
  expect(nutriments.fiber100, closeTo(2, 0.001));
  expect(nutriments.monounsaturatedFat100, closeTo(3, 0.001));
  expect(nutriments.polyunsaturatedFat100, closeTo(1, 0.001));
  expect(nutriments.transFat100, closeTo(0.2, 0.001));
  expect(nutriments.cholesterol100, closeTo(20, 0.001));

  expect(nutriments.sodium100, closeTo(40, 0.001));
  expect(nutriments.potassium100, closeTo(60, 0.001));
  expect(nutriments.magnesium100, closeTo(80, 0.001));
  expect(nutriments.calcium100, closeTo(100, 0.001));
  expect(nutriments.iron100, closeTo(1.2, 0.001));
  expect(nutriments.zinc100, closeTo(1.4, 0.001));
  expect(nutriments.phosphorus100, closeTo(120, 0.001));

  expect(nutriments.vitaminA100, closeTo(140, 0.001));
  expect(nutriments.vitaminC100, closeTo(16, 0.001));
  expect(nutriments.vitaminD100, closeTo(4, 0.001));
  expect(nutriments.vitaminB6100, closeTo(0.8, 0.001));
  expect(nutriments.vitaminB12100, closeTo(2.4, 0.001));
  expect(nutriments.niacin100, closeTo(3.6, 0.001));

  expect(result.intakes.single.amount, 50);
  expect(result.intakes.single.unit, 'g');
});

}
