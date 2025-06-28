extension StringExtensions on String {
  String get titleCase =>
      splitMapJoin(' ', onNonMatch: (s) => s[0].toUpperCase() + s.substring(1));
  String get pascalCase => titleCase.replaceAll(RegExp(r' '), '');
}
