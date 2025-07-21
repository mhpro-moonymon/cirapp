import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/conversations_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/search_users_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'تطبيق المحادثة',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Arial',
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routerConfig: _createRouter(authProvider),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/conversations' : '/login',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthenticating = authProvider.isLoading;
        final isOnLoginPage = state.location == '/login';
        final isOnRegisterPage = state.location == '/register';

        // If still authenticating, stay where we are
        if (isAuthenticating) return null;

        // If not authenticated and not on auth pages, go to login
        if (!isAuthenticated && !isOnLoginPage && !isOnRegisterPage) {
          return '/login';
        }

        // If authenticated and on auth pages, go to conversations
        if (isAuthenticated && (isOnLoginPage || isOnRegisterPage)) {
          return '/conversations';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/conversations',
          builder: (context, state) => const ConversationsScreen(),
        ),
        GoRoute(
          path: '/chat/:conversationId',
          builder: (context, state) {
            final conversationId = state.params['conversationId']!;
            return ChatScreen(conversationId: conversationId);
          },
        ),
        GoRoute(
          path: '/search-users',
          builder: (context, state) => const SearchUsersScreen(),
        ),
      ],
    );
  }
}