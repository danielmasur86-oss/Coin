import 'package:material_ui/material_ui.dart';

import 'models/explanation.dart';
import 'models/profile.dart';
import 'services/api_client.dart';
import 'services/purchases.dart';
import 'services/storage.dart';

/// App-wide state: profile, premium status and the free-task counter.
class AppState extends ChangeNotifier {
  AppState({required this.storage, required this.api, required this.purchases})
      : _profile = storage.profile,
        _history = storage.history;

  final Storage storage;
  final ApiClient api;
  final PurchaseService purchases;

  Profile? _profile;
  Profile? get profile => _profile;

  bool _premium = false;
  bool get premium => _premium;

  int? _remainingFree;
  int? get remainingFree => _remainingFree;

  List<HistoryEntry> _history;
  List<HistoryEntry> get history => _history;

  Locale get locale => Locale(_profile?.language ?? 'de');

  Future<void> refreshStatus() async {
    final storePremium = await purchases.isPremium();
    try {
      final q = await api.quota();
      _premium = storePremium || q.premium;
      _remainingFree = q.remainingFree;
    } on ApiException {
      _premium = storePremium;
    }
    notifyListeners();
  }

  Future<void> saveProfile(Profile p) async {
    await storage.saveProfile(p);
    _profile = p;
    notifyListeners();
  }

  void updateRemaining(int? remaining) {
    _remainingFree = remaining;
    if (remaining == null) _premium = true;
    notifyListeners();
  }

  Future<void> addHistory(HistoryEntry e) async {
    await storage.addHistory(e);
    _history = storage.history;
    notifyListeners();
  }

  Future<void> deleteLocalData() async {
    await storage.clearPersonalData();
    _profile = null;
    _history = const [];
    notifyListeners();
  }

  void setPremium() {
    _premium = true;
    _remainingFree = null;
    notifyListeners();
  }
}

/// Makes [AppState] available to the widget tree.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
