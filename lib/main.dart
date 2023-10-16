import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {

  final Map<String, WidgetBuilder> routes = {
    WelcomeScreen.id: (context) => WelcomeScreen(), // HomeScreen is the default route
    LoginScreen.id: (context) => LoginScreen(),
    RegistrationScreen.id: (context) => RegistrationScreen(),
    ChatScreen.id:(context) => ChatScreen(),
    // Add more routes as needed
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: routes,
    );
  }
}