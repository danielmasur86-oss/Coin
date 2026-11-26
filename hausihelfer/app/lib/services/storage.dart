import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/explanation.dart';
import '../models/profile.dart';

/// Local storage: anonymous user id, profile and task history. Nothing leaves the device
/// except the photo the parent chooses to send for an explanation.
class Storage {
  Storage(this._prefs);

  static const _kUserId = 'user_id';
  static const _kProfile = 'profile';
  static const _kHistory = 'history';
  static const maxHistory = 30;

  final SharedPreferences _prefs;

  static Future<Storage> open() async => Storage(await SharedPreferences.getInstance());

  /// Random id, used for the free quota and to link RevenueCat purchases.
  String get userId {
    var id = _prefs.getString(_kUserId);
    if (id == null) {
      id = const Uuid().v4();
      _prefs.setString(_kUserId, id);
    }
    return id;
  }

  Profile? get profile {
    final raw = _prefs.getString(_kProfile);
    return raw == null ? null : Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(Profile p) => _prefs.setString(_kProfile, jsonEncode(p.toJson()));

  List<HistoryEntry> get history {
    final raw = _prefs.getStringList(_kHistory) ?? const [];
    final out = <HistoryEntry>[];
    for (final s in raw) {
      try {
        out.add(HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // Skip entries written by an older, incompatible version.
      }
    }
    return out;
  }

  Future<void> addHistory(HistoryEntry e) {
    final raw = _prefs.getStringList(_kHistory) ?? <String>[];
    raw.insert(0, jsonEncode(e.toJson()));
    return _prefs.setStringList(_kHistory, raw.take(maxHistory).toList());
  }
}
