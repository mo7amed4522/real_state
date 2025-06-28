import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_state_app/core/assets/app_assets.dart';

class CountryCode {
  final String name;
  final String flag;
  final String code;
  final String dialCode;

  CountryCode({
    required this.name,
    required this.flag,
    required this.code,
    required this.dialCode,
  });

  factory CountryCode.fromJson(Map<String, dynamic> json) {
    return CountryCode(
      name: json['name'],
      flag: json['flag'],
      code: json['code'],
      dialCode: json['dial_code'],
    );
  }
}

class SearchableCountryCodeDropdown extends StatefulWidget {
  final String selectedCode;
  final String selectedDialCode;
  final void Function(CountryCode) onChanged;

  const SearchableCountryCodeDropdown({
    super.key,
    required this.selectedCode,
    required this.selectedDialCode,
    required this.onChanged,
  });

  @override
  State<SearchableCountryCodeDropdown> createState() =>
      _SearchableCountryCodeDropdownState();
}

class _SearchableCountryCodeDropdownState
    extends State<SearchableCountryCodeDropdown> {
  List<CountryCode> _countryCodes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCountryCodes();
  }

  Future<void> _loadCountryCodes() async {
    final String data = await rootBundle.loadString(AppAssets.countryCode);
    final List<dynamic> jsonResult = json.decode(data);
    setState(() {
      _countryCodes = jsonResult.map((e) => CountryCode.fromJson(e)).toList();
      _loading = false;
    });
  }

  void _showCountryPicker() async {
    final selected = await showDialog<CountryCode>(
      context: context,
      builder: (context) {
        String search = '';
        List<CountryCode> filtered = _countryCodes;
        return StatefulBuilder(
          builder: (context, setState) {
            filtered = _countryCodes
                .where(
                  (c) =>
                      c.name.toLowerCase().contains(search.toLowerCase()) ||
                      c.dialCode.contains(search) ||
                      c.code.toLowerCase().contains(search.toLowerCase()),
                )
                .toList();
            return AlertDialog(
              title: const Text('Select Country Code'),
              content: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search country',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() => search = value),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final country = filtered[i];
                          return ListTile(
                            leading: Text(country.flag),
                            title: Text(
                              '${country.name} (${country.dialCode})',
                            ),
                            onTap: () => Navigator.of(context).pop(country),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (selected != null) widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    }
    final selected = _countryCodes.firstWhere(
      (c) =>
          c.code == widget.selectedCode &&
          c.dialCode == widget.selectedDialCode,
      orElse: () => _countryCodes.first,
    );
    return GestureDetector(
      onTap: _showCountryPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.flag),
            const SizedBox(width: 8),
            Text(
              selected.dialCode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
