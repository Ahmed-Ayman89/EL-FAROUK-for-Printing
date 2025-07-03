import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/app_colors.dart';
import 'config/app_constants.dart';
import 'features/pos/cubit/pos_cubit.dart';
import 'features/pos/data/pos_data_source.dart';
import 'features/pos/presentation/pos_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PosCubit>(
          create: (context) => PosCubit(PosDataSource()),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData.light().copyWith(
          primaryColor: AppColors.primaryBlueLight,
          buttonTheme: const ButtonThemeData(
            buttonColor: AppColors.primaryBlueLight,
            textTheme: ButtonTextTheme.primary,
          ),
          cardColor: AppColors.lightBackground, // For the main frame background
          scaffoldBackgroundColor: Colors.grey[200], // Overall app background
        ),
        darkTheme: ThemeData.dark().copyWith(
          // Dark theme adjustments
          primaryColor: AppColors.primaryBlue,
          buttonTheme: const ButtonThemeData(
            buttonColor: AppColors.primaryBlue,
            textTheme: ButtonTextTheme.primary,
          ),
          cardColor: AppColors.darkBackground, // For the main frame background
          scaffoldBackgroundColor: Colors.black, // Overall app background
        ),
        home: const PosScreen(),
      ),
    );
  }
}
