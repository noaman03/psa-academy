import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveKeepSignedInPreference(bool keepSignedIn) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('keepSignedIn', keepSignedIn);
}

Future<bool> getKeepSignedInPreference() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('keepSignedIn') ?? false;
}
