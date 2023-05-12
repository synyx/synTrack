import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syntrack/cubit/booking_cubit.dart';
import 'package:syntrack/cubit/task_search_cubit.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';
import 'package:syntrack/cubit/work_interface_cubit.dart';
import 'package:syntrack/repository/data/latest_bookings_data_provider.dart';
import 'package:syntrack/repository/work_repository.dart';
import 'package:syntrack/router.dart';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documentsDir = await getApplicationDocumentsDirectory();
  const appDirName = kDebugMode ? 'synTrack_dev' : 'synTrack';
  final appDir = await Directory('${documentsDir.absolute.path}/$appDirName').create();

  await createHydratedBoxBackup(appDir);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: appDir,
  );

  runApp(SynTrack());
}

Future<void> createHydratedBoxBackup(Directory appDir, {int maxBackups = 10}) async {
  final originalFile = File('${appDir.path}/hydrated_box.hive');
  final backupsDir = await Directory('${appDir.path}/backups').create();

  if (await originalFile.exists()) {
    final backupFiles = await backupsDir
        .list(followLinks: false, recursive: false)
        .where((file) {
          final stat = file.statSync();
          final fileName = path.basename(file.path);
          return stat.type == FileSystemEntityType.file && fileName.startsWith("backup_");
        })
        .map((file) => File(file.path))
        .toList();

    if (backupFiles.length >= maxBackups) {
      backupFiles.sort((a, b) => b.path.compareTo(a.path));
      for (final backupToDelete in backupFiles.sublist(maxBackups - 1)) {
        await backupToDelete.delete();
      }
    }

    await originalFile.copy('${backupsDir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.hive');
  }
}

class SynTrack extends StatelessWidget {
  static const primarySwatch = Colors.blue;
  final _appRouter = AppRouter();

  SynTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      lazy: false,
      create: (context) => WorkRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TimeEntriesCubit(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) {
              final workInterfaceCubit = WorkInterfaceCubit();
              context.read<WorkRepository>().init(
                    workInterfaceCubit.state,
                    workInterfaceCubit.stream,
                    LatestBookingsDataProvider(timeEntriesCubit: context.read<TimeEntriesCubit>()),
                  );
              return workInterfaceCubit;
            },
          ),
          BlocProvider(
            create: (context) => TaskSearchCubit(
              context.read<WorkRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TimeTrackingCubit(context.read<TimeEntriesCubit>()),
          ),
          BlocProvider(
            create: (context) => BookingCubit(
              context.read<TimeEntriesCubit>(),
              context.read<WorkRepository>(),
            ),
          ),
        ],
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp.router(
              supportedLocales: const [Locale('de')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              title: 'synTrack',
              theme: ThemeData(
                primarySwatch: primarySwatch,
                useMaterial3: false,
              ),
              routerDelegate: _appRouter.delegate(),
              routeInformationParser: _appRouter.defaultRouteParser(),
            );
          },
        ),
      ),
    );
  }
}
