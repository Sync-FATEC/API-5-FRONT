import 'package:api2025/ui/views/alerts/alerts_screen.dart';
import 'package:api2025/ui/views/merchandise/merchandise_menu_screen.dart';
import 'package:api2025/ui/views/orders/orders_screen.dart';
import 'package:api2025/ui/views/reports/reports_screen.dart';
import 'package:api2025/ui/views/stock/stock_screen.dart';
import 'package:api2025/ui/views/users/users_screen.dart';
import 'package:api2025/ui/widgets/scan_or_manual_dialog.dart';
import 'package:api2025/ui/views/orders/widgets/orders_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:api2025/ui/views/login/login_screen.dart';
import 'package:api2025/ui/views/home/home_screen.dart';
import 'package:api2025/ui/views/forgot_password/forgot_password_screen.dart';
import 'package:api2025/ui/views/section/section_screen.dart';
import 'package:api2025/ui/views/profile/profile_screen.dart';
import 'package:api2025/core/providers/user_provider.dart';
import 'package:api2025/core/providers/stock_provider.dart';
import 'package:api2025/core/providers/section_provider.dart';
import 'package:api2025/core/providers/dashboard_provider.dart';
import 'package:api2025/core/providers/merchandise_type_provider.dart';
import 'package:api2025/core/providers/order_provider.dart';
import 'package:api2025/core/providers/alert_provider.dart';
import 'firebase_options.dart';
import 'package:api2025/core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env");

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => SectionProvider()),
        ChangeNotifierProvider(create: (_) => MerchandiseTypeProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Controle de estoque',
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF9F9F9),
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.bluePrimary),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/stock-selection': (context) => const StockSelectionScreen(),
          '/sections': (context) => const SectionScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/users': (context) => const UsersScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/orders-list': (context) => const OrdersListScreen(),
          '/alerts': (context) => const AlertsScreen(),
          '/dashboard': (context) => const ReportsScreen(),
          '/merchandise-menu': (context) {
            Function(String)? updateScanResult;

            return MerchandiseMenuScreen(
              onInit: (updateFn) {
                updateScanResult = updateFn;
              },
              onScanQr: () {
                showDialog(
                  context: context,
                  builder: (context) => ScanOrManualDialog(
                    onResult: (ficha) {
                      // Atualiza o estado da tela com o resultado do scan
                      if (updateScanResult != null) {
                        updateScanResult!(ficha);
                      }
                      Navigator.of(context).pop(); // Fecha o diálogo
                    },
                  ),
                );
              },
            );
          },
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
