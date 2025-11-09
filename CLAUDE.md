# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

synTrack is a Flutter-based time tracking and booking tool that integrates with multiple work management systems (Redmine and ERPNext). Users can search for tasks, track time locally, and book time entries to external systems.

## Development Commands

### Setup
```bash
flutter pub get
```

### Code Generation
The project uses code generators for routing, serialization, and state management.

Run once:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Watch mode (recommended during development):
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running the Application
```bash
# For desktop platforms
flutter run -d linux
flutter run -d macos
flutter run -d windows
```

### Building
```bash
flutter build linux --release
flutter build macos --release
```

## Architecture

### State Management
The app uses **BLoC/Cubit pattern** with `flutter_bloc` and `hydrated_bloc` for persistent state:

- **TimeTrackingCubit** (`lib/cubit/time_tracking_cubit.dart`): Manages active time tracking sessions
- **TimeEntriesCubit** (`lib/cubit/time_entries_cubit.dart`): Stores all time entries persistently
- **BookingCubit** (`lib/cubit/booking_cubit.dart`): Handles booking/unbooking time entries to external systems
- **TaskSearchCubit** (`lib/cubit/task_search_cubit.dart`): Manages task search across multiple work interfaces
- **WorkInterfaceCubit** (`lib/cubit/work_interface_cubit.dart`): Stores configurations for Redmine and ERPNext instances
- **TimeEntriesFilterCubit** (`lib/cubit/time_entries_filter_cubit.dart`): Manages filtering of time entries list
- **ThemeModeCubit** (`lib/cubit/theme_mode_cubit.dart`): Manages dark/light theme preference

### Repository Pattern
**WorkRepository** (`lib/repository/work_repository.dart`) is the central abstraction that:
- Coordinates between multiple work interface configurations
- Delegates to specific data providers (Redmine, ERPNext, Latest Bookings)
- Merges search results from multiple sources using `StreamGroup`
- Routes booking/deletion operations to the correct provider

### Data Providers
Data providers implement the `WorkDataProvider<Config>` interface (`lib/repository/data/work_data_provider.dart`):

- **RedmineDataProvider** (`lib/repository/data/remine_data_provider.dart`): Integrates with Redmine API
- **ErpNextDataProvider** (`lib/repository/data/erpnext_data_provider.dart`): Integrates with ERPNext API
- **LatestBookingsDataProvider** (`lib/repository/data/latest_bookings_data_provider.dart`): Provides recently booked tasks as search results

Each provider handles:
- Task search with streaming results
- Time entry booking
- Booking deletion
- Fetching available activities for tasks

### Core Models
Models use `built_value` for immutability and serialization:

- **TimeEntry** (`lib/model/common/time_entry.dart`): Represents a tracked time period with optional booking ID
- **Task** (`lib/model/common/task.dart`): Represents a bookable task with work interface ID and available activities
- **Activity** (`lib/model/common/activity.dart`): Represents activity types (e.g., "Development", "Testing")
- **TaskSearchResult** (`lib/model/common/task_search_result.dart`): Wrapper for streaming search results

Work interface-specific models are in:
- `lib/model/work/redmine/` - Redmine API models
- `lib/model/work/erpnext/` - ERPNext API models

### Routing
Uses `auto_route` package with routes defined in `lib/router.dart`:
- TrackRoute (main page)
- SettingsRoute
- RedmineEditRoute (edit Redmine configuration)
- ErpNextEditRoute (edit ERPNext configuration)
- WorkInterfaceSelectorRoute (select work interface)

### Persistence
`HydratedBloc` automatically persists cubit state to:
- **Production**: `~/Documents/synTrack/`
- **Debug**: `~/Documents/synTrack_dev/`

The app creates automatic backups of `hydrated_box.hive` (up to 10 backups) on startup.

## Key Workflows

### Time Tracking Flow
1. User selects a task via search (TaskSearchCubit)
2. User starts tracking (TimeTrackingCubit stores active session)
3. User stops tracking → creates TimeEntry (TimeEntriesCubit stores persistently)
4. User books TimeEntry → BookingCubit calls WorkRepository → delegates to appropriate data provider
5. Booking succeeds → TimeEntry updated with bookingId

### Multi-Source Search
When searching, WorkRepository creates merged stream from:
- All configured Redmine instances
- All configured ERPNext instances
- Latest booked tasks (cached locally)

Results stream in real-time as each source responds.

## Important Implementation Details

- All DateTime values are stored in UTC internally
- Time entries are automatically sorted by start time (descending) in TimeEntriesCubit
- Generated files (`.g.dart`, `.gr.dart`) must be regenerated after model or route changes
- Each work interface configuration has a unique ID used to route operations
- Booking operations are queued (BookingCubit tracks in-progress bookings)
- The app supports multiple instances of the same work interface type (e.g., multiple Redmine servers)
- make very simple commit messages with max 2 lines