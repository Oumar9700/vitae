import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'di/injection_container.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';
import 'shared/services/app_router.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // OpenFoodFacts SDK
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'Vitae',
    version: '1.0.0',
    comment: 'Flutter Nutrition App',
    url: 'https://github.com/Oumar9700',
  );
  OpenFoodAPIConfiguration.globalLanguages = const [OpenFoodFactsLanguage.FRENCH];
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.FRANCE;

  // Dependency injection
  await initDependencies();

  // Portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const VitaeApp());
}

class VitaeApp extends StatefulWidget {
  const VitaeApp({super.key});

  @override
  State<VitaeApp> createState() => _VitaeAppState();
}

class _VitaeAppState extends State<VitaeApp> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(AuthCheckRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Vitae',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router(_authBloc),
      ),
    );
  }
}
