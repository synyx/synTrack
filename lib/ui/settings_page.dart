import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/work_interface_cubit.dart';
import 'package:syntrack/model/common/task_search_origin.dart';
import 'package:syntrack/model/work/erpnext/erpnext_config.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';
import 'package:syntrack/router.gr.dart';
import 'package:syntrack/ui/widget/work_interface_icon.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final combinedConfigs = context.watch<WorkInterfaceCubit>().state.combinedConfigs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: AppBar(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    title: const Text('Work Interfaces'),
                    automaticallyImplyLeading: false,
                    shadowColor: Colors.transparent,
                    actions: [
                      PopupMenuButton(
                        icon: const Icon(Icons.add),
                        itemBuilder: (context) => <PopupMenuEntry>[
                          PopupMenuItem(
                            child: const ListTile(
                              leading: WorkInterfaceIcon(
                                origin: TaskSearchOrigin.redmine,
                                padding: EdgeInsets.all(10),
                              ),
                              title: Text('Redmine'),
                            ),
                            onTap: () => context.router.push(RedmineEditRoute()),
                          ),
                          PopupMenuItem(
                            child: const ListTile(
                              leading: WorkInterfaceIcon(
                                origin: TaskSearchOrigin.erpNext,
                                padding: EdgeInsets.all(10),
                              ),
                              title: Text('ERPNext'),
                            ),
                            onTap: () => context.router.push(ErpNextEditRoute()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: combinedConfigs.length,
                    itemBuilder: (context, index) {
                      final config = combinedConfigs[index];

                      if (config is RedmineConfig) {
                        return ListTile(
                          title: Text(config.name),
                          onTap: () => context.router.push(RedmineEditRoute(initialConfig: config)),
                          leading: const WorkInterfaceIcon(
                            origin: TaskSearchOrigin.redmine,
                            borderRadius: 10,
                            padding: EdgeInsets.all(5),
                          ),
                          trailing: IconButton(
                            onPressed: () => context.read<WorkInterfaceCubit>().deleteConfig(config.id),
                            icon: const Icon(Icons.delete),
                          ),
                        );
                      } else if (config is ErpNextConfig) {
                        return ListTile(
                          title: Text(config.name),
                          onTap: () => context.router.push(ErpNextEditRoute(initialConfig: config)),
                          leading: const WorkInterfaceIcon(
                            origin: TaskSearchOrigin.erpNext,
                            borderRadius: 10,
                            padding: EdgeInsets.all(5),
                          ),
                          trailing: IconButton(
                            onPressed: () => context.read<WorkInterfaceCubit>().deleteConfig(config.id),
                            icon: const Icon(Icons.delete),
                          ),
                        );
                      } else {
                        return const ListTile(
                          title: Text('Unknown Work Interface'),
                        );
                      }
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
