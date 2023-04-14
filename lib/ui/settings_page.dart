import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/work_interface_cubit.dart';
import 'package:syntrack/router.gr.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: AppBar(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    title: Text('Work Interfaces'),
                    automaticallyImplyLeading: false,
                    shadowColor: Colors.transparent,
                    actions: [
                      IconButton(
                        onPressed: () => context.router.push(RedmineEditRoute()),
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: context.watch<WorkInterfaceCubit>().state.redmineConfigs.length,
                    itemBuilder: (context, index) {
                      final redmineConfig = context.watch<WorkInterfaceCubit>().state.redmineConfigs[index];
                      return ListTile(
                        title: Text(redmineConfig.name),
                        onTap: () => context.router.push(RedmineEditRoute(initialConfig: redmineConfig)),
                        trailing: IconButton(
                          onPressed: () => context.read<WorkInterfaceCubit>().deleteRedmineConfig(redmineConfig),
                          icon: Icon(Icons.delete),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
