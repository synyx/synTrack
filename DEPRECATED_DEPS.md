# Deprecated & Unmaintained Dependencies Report

## Critical Issues

### 🔴 Security Vulnerabilities

**archive (transitive via flutter_launcher_icons)**
- Current: 3.3.7
- Status: Has 2 security advisories
- Issues:
  - CVE: Path traversal (GHSA-9v85-q87q-g4vg)
  - CVE: Filename spoofing (GHSA-r285-q736-9v95)
- Fix: Upgrade to 4.0.7
- Impact: Low (only used during build for icon generation)

### 🟡 Retracted Packages

**flutter_keyboard_visibility (transitive)**
- Current: 5.4.2 (RETRACTED)
- Status: Publisher retracted this version
- Fix: Upgrade to 6.0.0
- Used by: flutter_typeahead
- Impact: Medium (used in search UI)

### 🟠 Discontinued Packages

These are transitive dependencies that are discontinued but still work:

**build_resolvers**
- Status: Package discontinued by maintainer
- Used by: build_runner ecosystem
- Fix: Will be replaced automatically when upgrading build_runner
- Impact: Low (dev dependency only)

**build_runner_core**
- Status: Package discontinued by maintainer
- Used by: build_runner ecosystem
- Fix: Will be replaced automatically when upgrading build_runner
- Impact: Low (dev dependency only)

**js**
- Status: Package discontinued by Dart team
- Used by: Web-related packages
- Fix: Flutter SDK handles this automatically
- Impact: None (not targeting web)

## Direct Dependency Analysis

### Outdated Major Versions

| Package | Current | Latest | Status | Risk |
|---------|---------|--------|--------|------|
| auto_route | 7.1.0 | 10.2.0 | Maintained | High - Breaking changes |
| flutter_bloc | 8.1.2 | 9.1.1 | Maintained | Medium - Core to app |
| hydrated_bloc | 9.1.0 | 10.1.1 | Maintained | Medium - Core to app |
| http | 0.13.6 | 1.5.0 | Maintained | Medium - API calls |
| uuid | 3.0.7 | 4.5.2 | Maintained | Low - Simple API |
| sizer | 2.0.15 | 3.1.3 | Maintained | Low - UI sizing |
| copy_with_extension | 5.0.2 | 10.0.1 | Maintained | Medium - Code gen |

### Custom/Forked Dependencies

**flutter_typeahead**
- Source: Git fork (https://github.com/enoy19/flutter_typeahead.git)
- Branch: streamed
- Status: Custom fork
- Issue: Not using official package
- Recommendation: Check if official package now supports streaming
- Official latest: 4.8.0

### Well-Maintained Dependencies

These are up-to-date or have minor updates only:
- cupertino_icons ✓
- equatable ✓
- path_provider ✓
- built_value ✓
- flutter_lints ✓

## Recommendations

### Immediate Actions (Do Now)

1. **Fix security issues** - Add dependency overrides:
```yaml
dependency_overrides:
  archive: ^4.0.7
  flutter_keyboard_visibility: ^6.0.0
```

### Short Term (This Month)

2. **Replace custom flutter_typeahead fork**
   - Check if official package supports streaming
   - If yes, switch back to pub.dev version
   - If no, document why fork is needed

3. **Update minor versions**
   - Run `flutter pub upgrade` for safe updates

### Medium Term (Next Quarter)

4. **Major version upgrades**
   - Plan auto_route 10.x migration (biggest change)
   - Update bloc packages together
   - Update code generation tools

5. **Modernize linting**
   - Upgrade flutter_lints to 6.0
   - Fix new lint warnings

### Long Term (Ongoing)

6. **Establish update policy**
   - Review dependencies quarterly
   - Run `flutter pub outdated` monthly
   - Set up Dependabot on GitHub

## Migration Priority

### Priority 1 (Critical) - Do Immediately
- archive (security)
- flutter_keyboard_visibility (retracted)

### Priority 2 (High) - Within 1 Month
- flutter_typeahead (evaluate fork necessity)
- auto_route (major version behind)

### Priority 3 (Medium) - Within 3 Months
- flutter_bloc + hydrated_bloc
- http
- build_runner ecosystem

### Priority 4 (Low) - When Convenient
- uuid
- sizer
- copy_with_extension
- Minor version bumps

## Testing Strategy

For each upgrade:
1. Create feature branch
2. Update single package or related group
3. Run code generation
4. Run `dart fix --apply`
5. Fix compilation errors
6. Test affected features
7. Create PR
8. Deploy to staging

## Alternative: Replace Packages

Consider if any packages can be replaced:

**sizer** → Could use MediaQuery directly
- Pro: Less dependency
- Con: More boilerplate

**flutter_typeahead** → Use official package or build custom
- Pro: No fork maintenance
- Con: May lose streaming feature

**uuid** → Use built-in Dart capabilities
- Pro: Less dependency
- Con: uuid package is well-tested

## Automated Checks

Add to CI/CD:
```bash
# Check for outdated packages
flutter pub outdated --exit-if-needed

# Check for security advisories
flutter pub outdated | grep -i advisory

# Run analysis
flutter analyze
```

## Notes

- Most dependencies are well-maintained
- Main issue is version lag (7-10 major versions behind)
- No abandonware in direct dependencies
- Custom fork needs evaluation
- Build succeeds despite warnings
