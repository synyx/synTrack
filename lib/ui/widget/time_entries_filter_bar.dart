import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_entries_filter_cubit.dart';
import 'package:syntrack/cubit/work_interface_cubit.dart';
import 'package:syntrack/ui/widget/work_interface_icon.dart';

class TimeEntriesFilterBar extends StatefulWidget {
  const TimeEntriesFilterBar({super.key});

  @override
  State<TimeEntriesFilterBar> createState() => _TimeEntriesFilterBarState();
}

class _TimeEntriesFilterBarState extends State<TimeEntriesFilterBar> {
  bool _searchShown = false;
  bool _filtersShown = false;
  final _searchBarFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    const bottomAppBarHeight = 85.0;
    const bottomAppBarHeightExpansion = 150.0;

    return BottomAppBar(
      height: _filtersShown ? bottomAppBarHeight + bottomAppBarHeightExpansion : bottomAppBarHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (_filtersShown) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 100.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: _buildFilters(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              IconButton(
                tooltip: 'Filters',
                icon: Icon(_filtersShown ? Icons.filter_list_off : Icons.filter_list),
                onPressed: () => toggleFiltersVisibility(context),
              ),
              if (!_searchShown)
                IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search),
                  onPressed: () => setSearchBarVisibility(context, true),
                ),
              if (_searchShown)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 100.0),
                    child: SearchBar(
                      onChanged: (query) => context.read<TimeEntriesFilterCubit>().debouncedQuery(query),
                      focusNode: _searchBarFocusNode,
                      leading: const Icon(Icons.search),
                      hintText: 'Search Time Entries',
                      trailing: [
                        IconButton(
                          onPressed: () => setSearchBarVisibility(context, false),
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 6,
          runSpacing: 6,
          children: [
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  const Text('Work Interfaces'),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: context.watch<WorkInterfaceCubit>().state.combinedConfigs.map((e) {
                      final workInterfaceName = context.read<WorkInterfaceCubit>().getNameFor(e);
                      final workInterfaceId = context.read<WorkInterfaceCubit>().getIdFor(e);
                      final selected =
                          context.watch<TimeEntriesFilterCubit>().state.filterWorkInterfaceId.contains(workInterfaceId);

                      return InkWell(
                        onTap: () => context.read<TimeEntriesFilterCubit>().setFilters((updates) =>
                            updates.filterWorkInterfaceId = {...updates.filterWorkInterfaceId ?? {}, workInterfaceId}),
                        child: Chip(
                          backgroundColor: selected ? Theme.of(context).colorScheme.primaryContainer : null,
                          onDeleted: selected
                              ? () => context.read<TimeEntriesFilterCubit>().setFilters(
                                    (updates) => updates.filterWorkInterfaceId = updates.filterWorkInterfaceId
                                            ?.where((element) => element != workInterfaceId)
                                            .toSet() ??
                                        {},
                                  )
                              : null,
                          label: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                child: WorkInterfaceIcon.fromConfig(e),
                              ),
                              const SizedBox(width: 4),
                              Text(workInterfaceName),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              child: CheckboxListTile(
                title: const Text('Booked'),
                value: context.watch<TimeEntriesFilterCubit>().state.filterBooked,
                onChanged: (value) => context.read<TimeEntriesFilterCubit>().setFilters((updates) {
                  updates.filterBooked = value;
                }),
                tristate: true,
              ),
            ),
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  Text(
                      'Duration ${((context.watch<TimeEntriesFilterCubit>().state.filterDuration?.inMinutes ?? 0) / 60).toStringAsFixed(2)}h'),
                  Slider(
                    value: context.watch<TimeEntriesFilterCubit>().state.filterDuration?.inMinutes.toDouble() ?? -1,
                    onChanged: (value) => context.read<TimeEntriesFilterCubit>().setFilters((updates) {
                      updates.filterDuration = value < 0
                          ? null
                          : Duration(
                              minutes: value.toInt(),
                            );
                    }),
                    min: -1,
                    max: 60 * 10,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text('Weekday'),
                SegmentedButton(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('Mon')),
                    ButtonSegment(value: 2, label: Text('Tue')),
                    ButtonSegment(value: 3, label: Text('Wed')),
                    ButtonSegment(value: 4, label: Text('Thu')),
                    ButtonSegment(value: 5, label: Text('Fri')),
                    ButtonSegment(value: 6, label: Text('Sat')),
                    ButtonSegment(value: 7, label: Text('Sun')),
                  ],
                  emptySelectionAllowed: true,
                  multiSelectionEnabled: true,
                  onSelectionChanged: (value) => context.read<TimeEntriesFilterCubit>().setFilters(
                        (updates) => updates.filterWeekday = value,
                      ),
                  selected: context.watch<TimeEntriesFilterCubit>().state.filterWeekday,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void setSearchBarVisibility(BuildContext context, bool visible) {
    setState(() {
      _searchShown = visible;
      if (visible) {
        _searchBarFocusNode.requestFocus();
      } else {
        context.read<TimeEntriesFilterCubit>().immediateQuery(null);
      }
    });
  }

  void toggleFiltersVisibility(BuildContext context) {
    setState(() {
      _filtersShown = !_filtersShown;

      if (!_filtersShown) {
        context.read<TimeEntriesFilterCubit>().clearFilters();
      }
    });
  }

  @override
  void dispose() {
    _searchBarFocusNode.dispose();
    super.dispose();
  }
}
