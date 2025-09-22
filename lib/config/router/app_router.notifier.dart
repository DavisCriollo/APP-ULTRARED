import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';

final goRouterNotifierProvider = Provider((ref) {
  return GoRouterNofier(ref.read(authProvider.notifier));
});

class GoRouterNofier extends ChangeNotifier {
  final AuthNotifier _authNotifier;
  AuthStatus _authStatus = AuthStatus.checking;

  GoRouterNofier(this._authNotifier) {
    _authNotifier.addListener((state) {
      setauthStatus(state.authStatus);
    });
  }

  AuthStatus get authStatus => _authStatus;
  setauthStatus(AuthStatus status) {
    _authStatus = status;
    notifyListeners();
  }
}
