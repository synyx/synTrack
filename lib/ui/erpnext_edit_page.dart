import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/work_interface_cubit.dart';
import 'package:syntrack/model/work/erpnext/erpnext_config.dart';

@RoutePage()
class ErpNextEditPage extends StatefulWidget {
  final ErpNextConfig? initialConfig;

  const ErpNextEditPage({Key? key, this.initialConfig}) : super(key: key);

  @override
  State<ErpNextEditPage> createState() => _ErpNextEditPageState();
}

class _ErpNextEditPageState extends State<ErpNextEditPage> {
  final _formKey = GlobalKey<FormState>();
  late ErpNextConfigBuilder erpNextConfig;

  @override
  void initState() {
    super.initState();
    erpNextConfig = widget.initialConfig?.toBuilder() ?? ErpNextConfigBuilder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERPNext'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () => _save(context),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: erpNextConfig.name,
                    decoration: const InputDecoration(hintText: 'Name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'invalid value' : null,
                    onSaved: (value) => erpNextConfig.name = value,
                  ),
                  TextFormField(
                    initialValue: erpNextConfig.baseUrl,
                    decoration: const InputDecoration(hintText: 'Base URL'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'invalid value' : null,
                    onSaved: (value) => erpNextConfig.baseUrl = value,
                  ),
                  TextFormField(
                    initialValue: erpNextConfig.apiKey,
                    decoration: const InputDecoration(hintText: 'API-Key'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'invalid value' : null,
                    onSaved: (value) => erpNextConfig.apiKey = value,
                  ),
                  TextFormField(
                    initialValue: erpNextConfig.apiSecret,
                    decoration: const InputDecoration(hintText: 'API-Secret'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'invalid value' : null,
                    onSaved: (value) => erpNextConfig.apiSecret = value,
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
      context.read<WorkInterfaceCubit>().addOrUpdateErpNextConfig(erpNextConfig.build());
      context.router.pop();
    }
  }
}
