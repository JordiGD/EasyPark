import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/driver_provider.dart';
import 'screens/driver_registration_screen.dart';
import 'screens/drivers_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: MaterialApp(
        title: 'EasyPark Driver App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const DriverRegistrationScreen(),
        routes: {
          '/': (context) => const DriverRegistrationScreen(),
          '/drivers-list': (context) => const DriversListScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
