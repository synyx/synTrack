import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/work_interface_cubit.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';
import 'package:syntrack/ui/widget/form/checkbox_list_tile_form_field.dart';

class RedmineEditPage extends StatefulWidget {
  final RedmineConfig? initialConfig;

  const RedmineEditPage({Key? key, this.initialConfig}) : super(key: key);

  @override
  _RedmineEditPageState createState() => _RedmineEditPageState();
}

class _RedmineEditPageState extends State<RedmineEditPage> {
  final _formKey = GlobalKey<FormState>();
  late RedmineConfigBuilder redmineConfig;

  @override
  void initState() {
    super.initState();
    redmineConfig = widget.initialConfig == null ? RedmineConfigBuilder() : widget.initialConfig!.toBuilder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redmine'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () => _save(context),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: redmineConfig.name,
                    decoration: InputDecoration(hintText: 'Name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Ungültiger Wert' : null,
                    onSaved: (value) => redmineConfig.name = value,
                  ),
                  TextFormField(
                    initialValue: redmineConfig.baseUrl,
                    decoration: InputDecoration(hintText: 'Base URL'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'invalid value' : null,
                    onSaved: (value) => redmineConfig.baseUrl = value,
                  ),
                  TextFormField(
                    initialValue: redmineConfig.apiKey,
                    decoration: InputDecoration(hintText: 'API-Key'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'invalid value' : null,
                    onSaved: (value) => redmineConfig.apiKey = value,
                  ),
                  TextFormField(
                    initialValue: redmineConfig.projectFilters,
                    decoration: InputDecoration(hintText: 'Project filters (comma separated)'),
                    onSaved: (value) => redmineConfig.projectFilters = value,
                  ),
                  CheckboxListTileFormField(
                    initialValue: redmineConfig.roundUp ?? true,
                    onSaved: (value) => redmineConfig.roundUp = value,
                    title: Text('Round up to 15 Minutes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<WorkInterfaceCubit>().addOrUpdateRedmineConfig(redmineConfig.build());
      context.router.pop();
    }
  }
}
