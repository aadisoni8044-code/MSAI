import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 1; // Default index 1 = Main Camera Screen

  int get currentIndex => _currentIndex;

  void setTab(int index) {
    if (index >= 0 && index <= 2) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void goToCamera() {
    _currentIndex = 1;
    notifyListeners();
  }

  void goToChat() {
    _currentIndex = 0;
    notifyListeners();
  }

  void goToStories() {
    _currentIndex = 2;
    notifyListeners();
  }
}
