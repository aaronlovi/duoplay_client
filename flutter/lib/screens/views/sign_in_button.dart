import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:duoplay/services/auth_service.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder to listen for AuthService changes
    final authService = GetIt.I<AuthService>();

    return _authServiceAwareBuilder(authService);
  }

  Widget _authServiceAwareBuilder(AuthService authService) => AnimatedBuilder(
    animation: authService,
    builder: (context, _) {
      final isSignedIn = authService.user != null;
      final photoUrl = authService.user?.photoUrl;

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
        ),
        onPressed:
            isSignedIn
                ? () async {
                  final shouldSignOut = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                            'Are you sure you want to sign out?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                  );
                  if (shouldSignOut == true) {
                    await authService.signOut();
                  }
                }
                : () async {
                  await authService.signInWithGoogle();
                },
        child:
            isSignedIn
                ? _signOutWidget(photoUrl, authService.user?.displayName)
                : const Text('Sign In'),
      );
    },
  );

  Widget _signOutWidget(String? photoUrl, String? displayName) {
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final hasUserName = displayName != null && displayName.isNotEmpty;
    final signOutText = hasUserName ? 'Sign Out ($displayName)' : 'Sign Out';
    return hasPhoto
        ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sign Out'),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(photoUrl),
              backgroundColor: Colors.transparent,
            ),
          ],
        )
        : Text(signOutText);
  }
}
