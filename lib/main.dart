import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hello_world/view/login_view.dart';
import 'package:hello_world/view/register_view.dart';
import 'package:hello_world/view/verify_email_view.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const Homepage(),
      routes: {
        "/login/": (context) => const LoginView(),
        "/register/": (context) => const RegisterView(),
        "/notes/": (context) => const NotesView()
      },
    );
  }
}

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              return const NotesView();
              // if (user.emailVerified) {
              //   return const NotesView();
              // } else {
              //   return const VerifyEmailView();
              // }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes View"), actions: [
        PopupMenuButton<MenuAction>(
          onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if (shouldLogout) {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("/login/", (route) => false);
                }
                break;
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text("Logout"),
              )
            ];
          },
        )
      ]),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Logout"))
        ],
      );
    },
  ).then((value) => value ?? false);
}
