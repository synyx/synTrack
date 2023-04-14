import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/work_interface_cubit.dart';
import 'package:syntrack/model/work/work_interface_configs.dart';

class WorkInterfaceSelectorPage extends StatelessWidget {
  const WorkInterfaceSelectorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Work Interface'),
        centerTitle: true,
      ),
      body: BlocBuilder<WorkInterfaceCubit, WorkInterfaceConfigs>(
        builder: (context, state) {
          final redmineConfigs = state.redmineConfigs;

          return ListView.builder(
            itemCount: redmineConfigs.length,
            itemBuilder: (context, index) {
              final config = redmineConfigs[index];
              return ListTile(
                onTap: () => context.router.pop(config),
                title: Text(config.name),
              );
            },
          );
        },
      ),
    );
  }
}
