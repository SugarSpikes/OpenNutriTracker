import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:opennutritracker/core/domain/usecase/save_recipe_usecase.dart';
import 'package:opennutritracker/core/utils/json_recipe_importer.dart';

typedef RecipeJsonFilePicker = Future<PlatformFile?> Function();

class ImportRecipesJsonResult {
  final int imported;
  final int skippedRecipes;
  final List<String> errorMessages;

  const ImportRecipesJsonResult({
    required this.imported,
    required this.skippedRecipes,
    required this.errorMessages,
  });
}

/// Picks a `.json` file from disk, validates the content via
/// [JsonRecipeImporter.parse], and persists each successfully-parsed
/// recipe via [SaveRecipeUseCase].
class ImportRecipesJsonUsecase {
  final SaveRecipeUseCase _saveRecipeUseCase;
  final RecipeJsonFilePicker _pickFile;

  ImportRecipesJsonUsecase(
    this._saveRecipeUseCase, {
    RecipeJsonFilePicker? pickFile,
  }) : _pickFile = pickFile ??
            (() async {
              final files = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['json'],
              );
              if (files.isEmpty) {
                return null;
              }
              return files.first;
            });

  /// Returns null when the user cancels the file picker.
  Future<ImportRecipesJsonResult?> importFromPickedFile() async {
    final picked = await _pickFile();

    if (picked == null || picked.path == null) {
      return null;
    }

    final file = File(picked.path!);
    final content = await file.readAsString(encoding: utf8);

    final parseResult = JsonRecipeImporter.parse(content);

    for (final imported in parseResult.recipes) {
      // SaveRecipeUseCase recomputes nutrition on save.
      // Preserve an explicit totalWeight from the JSON.
      await _saveRecipeUseCase.save(
        imported.recipe,
        totalWeightOverridden: imported.totalWeightOverridden,
      );
    }

    return ImportRecipesJsonResult(
      imported: parseResult.recipes.length,
      skippedRecipes: parseResult.errors.length,
      errorMessages: parseResult.errors,
    );
  }
}
