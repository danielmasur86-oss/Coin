import 'package:material_ui/material_ui.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../app_state.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/purchases.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, this.limitReached = false});
  final bool limitReached;

  static Route<void> route({bool limitReached = false}) => MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PaywallScreen(limitReached: limitReached),
      );

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<Package>? _packages;
  Package? _selected;
  bool _working = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_packages == null) _load();
  }

  Future<void> _load() async {
    final pkgs = await AppScope.of(context).purchases.packages();
    if (!mounted) return;
    setState(() {
      _packages = pkgs;
      // Pre-select the yearly plan: best value for the parent, best retention for us.
      _selected = pkgs.where((p) => p.packageType == PackageType.annual).firstOrNull ??
          pkgs.firstOrNull;
    });
  }

  Future<void> _buy() async {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _working = true);
    final outcome = await state.purchases.buy(_selected!);
    if (!mounted) return;
    setState(() => _working = false);
    switch (outcome) {
      case PurchaseOutcome.success:
        state.setPremium();
        navigator.pop();
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.failed:
        messenger.showSnackBar(SnackBar(content: Text(l.purchaseFailed)));
    }
  }

  Future<void> _restore() async {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _working = true);
    final ok = await state.purchases.restore();
    if (!mounted) return;
    setState(() => _working = false);
    messenger.showSnackBar(SnackBar(content: Text(ok ? l.restored : l.nothingToRestore)));
    if (ok) {
      state.setPremium();
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final packages = _packages;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Icon(Icons.workspace_premium, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(widget.limitReached ? l.limitReachedTitle : l.paywallTitle,
                style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(widget.limitReached ? l.limitReachedBody : l.paywallSubtitle,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            for (final b in [l.paywallBenefit1, l.paywallBenefit2, l.paywallBenefit3])
              ListTile(
                leading: Icon(Icons.check_circle, color: theme.colorScheme.primary),
                title: Text(b),
                dense: true,
              ),
            const SizedBox(height: 16),
            if (packages == null)
              const Center(child: CircularProgressIndicator())
            else if (packages.isEmpty)
              Text(l.paywallUnavailable, textAlign: TextAlign.center)
            else ...[
              RadioGroup<Package>(
                groupValue: _selected,
                onChanged: (p) => setState(() => _selected = p),
                child: Column(children: [
                  for (final p in packages)
                    Card(
                      child: RadioListTile<Package>(
                        value: p,
                        title: Text(p.storeProduct.title),
                        subtitle: Text(p.storeProduct.priceString),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 8),
              Text(l.paywallTrial, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _working || _selected == null ? null : _buy,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: _working
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.upgrade),
              ),
            ],
            TextButton(onPressed: _working ? null : _restore, child: Text(l.restorePurchases)),
          ],
        ),
      ),
    );
  }
}
