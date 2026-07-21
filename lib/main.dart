import 'package:axis/core%20/routing/navigation_services.dart';
import 'package:axis/core%20/services/local/simple_bloc_observer.dart';
import 'package:axis/core%20/theme/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core /routing/app_router.dart';
import 'core /routing/route_name.dart';
import 'core /services/service_locator.dart/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureInjection();

  if (kDebugMode) {
    Bloc.observer = SimpleBlocObserver();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
          theme: ThemeData(
          fontFamily: AppTextStyle.fontFamily,
          useMaterial3: true,
        ),
        title: 'Currency Exchange',
        onGenerateRoute: AppRouter.allRoutes,
        initialRoute: RouteName.onBoarding,
      ),
    );
  }
}


