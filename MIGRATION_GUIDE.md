# Dependency Migration Guide

This guide will help you update synTrack dependencies to their latest versions.

## Current Issues

### Security Advisories
- **archive 3.3.7** - Has 2 security vulnerabilities (path traversal, filename spoofing)
  - Current: 3.3.7
  - Latest: 4.0.7

### Retracted Packages
- **flutter_keyboard_visibility 5.4.2** - Version retracted by publisher
  - Current: 5.4.2
  - Latest: 6.0.0

### Discontinued Packages
- **build_resolvers** - Discontinued (transitive dependency)
- **build_runner_core** - Discontinued (transitive dependency)
- **js** - Discontinued (transitive dependency)

## Major Version Upgrades Required

### Core Dependencies
1. **auto_route** 7.1.0 → 10.2.0 (major version change)
   - Requires code changes for routing
   - Check migration guide: https://pub.dev/packages/auto_route/changelog

2. **flutter_bloc** 8.1.2 → 9.1.1 (major version change)
   - May require API changes
   - Check: https://pub.dev/packages/flutter_bloc/changelog

3. **hydrated_bloc** 9.1.0 → 10.1.1 (major version change)
   - Usually follows flutter_bloc changes
   - Check: https://pub.dev/packages/hydrated_bloc/changelog

4. **http** 0.13.6 → 1.5.0 (major version change)
   - API may have breaking changes
   - Check: https://pub.dev/packages/http/changelog

5. **uuid** 3.0.7 → 4.5.2 (major version change)
   - Check API changes: https://pub.dev/packages/uuid/changelog

6. **sizer** 2.0.15 → 3.1.3 (major version change)
   - UI sizing library, may affect layouts

### Dev Dependencies
1. **auto_route_generator** 7.0.0 → 10.2.5
   - Must match auto_route version

2. **build_runner** 2.4.2 → 2.10.1
   - Code generation tool

3. **flutter_lints** 2.0.1 → 6.0.0 (major version change)
   - Will add new lint rules, may require code fixes

## Migration Steps

### Step 1: Backup Current State
```bash
git checkout -b dependency-upgrade
git add .
git commit -m "backup before dependency upgrade"
```

### Step 2: Update Dependencies with Constraints
Run automatic upgrade:
```bash
flutter pub upgrade --major-versions
```

### Step 3: Run Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Apply Automatic Fixes
```bash
dart fix --apply
```

### Step 5: Check for Breaking Changes
Review these packages specifically:
- auto_route: Check routing code in `lib/router.dart`
- flutter_bloc: Check all Cubit and Bloc files in `lib/cubit/`
- http: Check API calls in `lib/repository/data/`

### Step 6: Test Build
```bash
flutter clean
flutter pub get
flutter run -d macos
```

### Step 7: Fix Lint Issues
```bash
flutter analyze
```

## Manual Migration Required

### auto_route 7.x → 10.x
Major changes in v10:
- Router generation syntax changed
- Navigation API updates
- Check file: `lib/router.dart`

**Before:**
```dart
@MaterialAutoRouter(...)
```

**After:**
```dart
@AutoRouterConfig()
```

### flutter_bloc 8.x → 9.x
- Minimal breaking changes expected
- Check `context.read()` and `context.watch()` usage

### http 0.13.x → 1.x
- Check import statements
- Response handling may have changed

## Testing Checklist

After migration, test:
- [ ] App builds without errors
- [ ] All routes navigate correctly
- [ ] Time tracking works
- [ ] Booking to Redmine works
- [ ] Booking to ERPNext works
- [ ] Settings save/load correctly
- [ ] Filter functionality works
- [ ] Theme switching works

## Rollback Plan

If migration fails:
```bash
git checkout main
git branch -D dependency-upgrade
```

## Alternative: Gradual Migration

Instead of upgrading all at once, upgrade in phases:

### Phase 1: Security Fixes Only
```yaml
dependency_overrides:
  archive: ^4.0.7
  flutter_keyboard_visibility: ^6.0.0
```

### Phase 2: Minor Updates
```bash
flutter pub upgrade
```

### Phase 3: Major Updates (one at a time)
Update auto_route first (biggest change):
```yaml
dependencies:
  auto_route: ^10.2.0
dev_dependencies:
  auto_route_generator: ^10.2.5
```

Then update bloc packages, then others.

## Estimated Time

- **Quick security fix**: 30 minutes
- **Full migration**: 4-8 hours (including testing)
- **Gradual migration**: 2-3 days (safer approach)

## Resources

- Flutter migration guides: https://docs.flutter.dev/release/breaking-changes
- Package changelogs on pub.dev
- auto_route migration: https://pub.dev/packages/auto_route#migration-guides
