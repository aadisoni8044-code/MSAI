import 'package:flutter/foundation.dart';
import '../models/filter_data.dart';
import '../models/filter_model.dart';

class FilterProvider extends ChangeNotifier {
  List<FilterModel> _filters = FilterData.filters;
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  double _filterIntensity = 1.0;

  List<FilterModel> get filters => _filters;
  int get selectedIndex => _selectedIndex;
  FilterModel get activeFilter => _filters[_selectedIndex];
  String get selectedCategory => _selectedCategory;
  double get filterIntensity => _filterIntensity;

  List<String> get categories {
    final cats = {'All'};
    for (var f in _filters) {
      cats.add(f.category);
    }
    return cats.toList();
  }

  List<FilterModel> get filteredFilters {
    if (_selectedCategory == 'All') {
      return _filters;
    }
    return _filters.where((f) => f.category == _selectedCategory).toList();
  }

  void selectFilter(int index) {
    if (index >= 0 && index < _filters.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void selectFilterById(String filterId) {
    final idx = _filters.indexWhere((f) => f.id == filterId);
    if (idx != -1) {
      _selectedIndex = idx;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setIntensity(double intensity) {
    _filterIntensity = intensity.clamp(0.0, 1.0);
    notifyListeners();
  }

  void nextFilter() {
    _selectedIndex = (_selectedIndex + 1) % _filters.length;
    notifyListeners();
  }

  void previousFilter() {
    _selectedIndex = (_selectedIndex - 1 + _filters.length) % _filters.length;
    notifyListeners();
  }
}
