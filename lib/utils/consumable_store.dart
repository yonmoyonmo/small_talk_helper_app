import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// 원모에게 적선한 흔적을 디바이스에 저장은 하지만 쓸 곳은 없다
class ConsumableStore {
  static const String _kPrefKey = 'consumables';
  static Future<void> _writes = Future.value();

  static Future<void> save(String id) {
    _writes = _writes.then((void _) => _doSave(id));
    return _writes;
  }

  static Future<void> consume(String id) {
    _writes = _writes.then((void _) => _doConsume(id));
    return _writes;
  }

  static Future<List<String>> load() async {
    return (await SharedPreferences.getInstance()).getStringList(_kPrefKey) ??
        [];
  }

  static Future<bool> isDonator() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList(_kPrefKey);
    print("Consumable list\n" + list.toString());
    if (list == null) return false;
    if (list.isEmpty)
      return false;
    else
      return true;
  }

  static Future<void> _doSave(String id) async {
    List<String> cached = await load();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cached.add(id);
    await prefs.setStringList(_kPrefKey, cached);
  }

  static Future<void> _doConsume(String id) async {
    List<String> cached = await load();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cached.remove(id);
    await prefs.setStringList(_kPrefKey, cached);
  }
}
