---
trigger: always_on
---

# Development Workflow & Processes

## Pre-Action Checks
- Before editing, read `pubspec.yaml` to confirm available packages and their versions.
- Search the codebase for existing utility classes before creating new ones to avoid duplication.

## Package Management
* **Pub Tool:** To manage packages, use the `pub` tool, if available.
* **External Packages:** If a new feature requires an external package, use the `pub_dev_search` tool, if it is available. Otherwise, identify the most suitable and stable package from pub.dev.
* **Adding Dependencies:** To add a regular dependency, use the `pub` tool, if it is available. Otherwise, run `flutter pub add <package_name>`.
* **Adding Dev Dependencies:** To add a development dependency, use the `pub` tool, if it is available, with `dev:<package name>`. Otherwise, run `flutter pub add dev:<package_name>`.
* **Dependency Overrides:** To add a dependency override, use the `pub` tool, if it is available, with `override:<package name>:1.0.0`. Otherwise, run `flutter pub add override:<package_name>:1.0.0`.
* **Removing Dependencies:** To remove a dependency, use the `pub` tool, if it is available. Otherwise, run `dart pub remove <package_name>`.

## Mandatory Verification Steps
After any code modification, the Agent MUST execute:
1. `flutter analyze`: Fix all errors and warnings before reporting completion.
2. `dart format .`: Ensure consistent code formatting.
3. If code generation is used (e.g., Freezed, Riverpod Generator): Run `flutter pub run build_runner build --delete-conflicting-outputs`.

## Completion Criteria
- Code must be bug-free and pass static analysis.
- Provide a brief summary of what was changed and why.
- If a new package was added, mention it in the summary.
