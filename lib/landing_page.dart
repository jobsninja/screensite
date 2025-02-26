import 'package:auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (previous, AuthState next) {
      if (next.isLoaded && next.user == null) {
        Navigator.pushNamed(context, '/login');
      } else if (next.isLoaded && next.user != null) {
        Navigator.pushNamed(context, '/search');
      }
    });

    return Center(
        child: SizedBox(
            height: 50, width: 50, child: CircularProgressIndicator()));
  }
}
