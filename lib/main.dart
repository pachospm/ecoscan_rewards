import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formatos de fechas en español
  await initializeDateFormatting('es', '');

  // Barra de estado transparente con iconos claros
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light
    )
  );
  runApp(const EconScanApp());
}

class EconScanApp extends StatelessWidget {
  const EconScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Todos los ViewModels disponibles en el árbol de widgets
      providers: [
        //ChangeNotifierProvider(create: (_) => AuthViewModel());
      ],
      child: MaterialApp(
        title: 'EconScan Rewards',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        //initialRoute: AppRoutes.splash,
        //onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
