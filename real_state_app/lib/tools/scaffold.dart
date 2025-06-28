// tool/scaffold.dart
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:real_state_app/core/utils/string_utils.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    debugPrint('Usage: dart scaffold.dart feature_name');
    return;
  }

  final featureName = args[0].toLowerCase();
  final featureDir = 'lib/features/$featureName';

  // Create folder structure
  Directory(featureDir).createSync(recursive: true);
  for (var dir in ['presentation', 'domain', 'data']) {
    Directory('$featureDir/$dir').createSync();
  }

  // Generate files
  generatePresentationFiles(featureName, featureDir);
  generateDomainFiles(featureName, featureDir);
  generateDataFiles(featureName, featureDir);

  debugPrint('✅ Feature "$featureName" created successfully!');
}

void generatePresentationFiles(String name, String dir) {
  final pagesDir = '$dir/presentation/pages';
  final widgetsDir = '$dir/presentation/widgets';
  final viewmodelsDir = '$dir/presentation/viewmodels';
  for (var d in [pagesDir, widgetsDir, viewmodelsDir]) {
    Directory(d).createSync();
  }

  File('$pagesDir/${name}_page.dart').writeAsStringSync('''
import 'package:flutter/material.dart';
class ${name.pascalCase}Page extends StatelessWidget {
  const ${name.pascalCase}Page({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('${name.titleCase}')), body: const Center(child: Text('Coming Soon')));
}
''');

  File('$viewmodelsDir/${name}_viewmodel.dart').writeAsStringSync('''
import 'package:flutter_bloc/flutter_bloc.dart';
class ${name.pascalCase}ViewModel extends Cubit<${name.pascalCase}State> {
  ${name.pascalCase}ViewModel() : super(${name.pascalCase}Initial());
}
abstract class ${name.pascalCase}State {}
class ${name.pascalCase}Initial extends ${name.pascalCase}State {}
''');
}

void generateDomainFiles(String name, String dir) {
  final entitiesDir = '$dir/domain/entities';
  final usecasesDir = '$dir/domain/usecases';
  final repositoriesDir = '$dir/domain/repositories';
  for (var d in [entitiesDir, usecasesDir, repositoriesDir]) {
    Directory(d).createSync();
  }

  File('$dir/domain/entities/${name}_entity.dart').writeAsStringSync('''
class ${name.pascalCase}Entity {
  final String id;
  ${name.pascalCase}Entity(this.id);
}
''');
}

void generateDataFiles(String name, String dir) {
  final modelsDir = '$dir/data/models';
  final datasourcesDir = '$dir/data/datasources';
  final mappersDir = '$dir/data/mappers';
  for (var d in [modelsDir, datasourcesDir, mappersDir]) {
    Directory(d).createSync();
  }

  File('$modelsDir/${name}_model.dart').writeAsStringSync('''
import 'package:json_annotation/json_annotation.dart';
part '${name}_model.g.dart';
@JsonSerializable()
class ${name.pascalCase}Model {
  final String id;
  ${name.pascalCase}Model(this.id);
  factory ${name.pascalCase}Model.fromJson(Map<String, dynamic> json) => _\$${name.pascalCase}ModelFromJson(json);
  Map<String, dynamic> toJson() => _\$${name.pascalCase}ModelToJson(this);
}
''');
}
