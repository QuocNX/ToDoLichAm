---
trigger: always_on
---

# Application Architecture

## Flutter Structure - GetX

### Project Structure
```
lib/
├── core/                         # Các phần hạ tầng chung, không phụ thuộc tính năng cụ thể
│   ├── constants/                # Hằng số toàn cục: colors, strings, API endpoints, paddings, regex...
│   ├── config/                   # Cấu hình app: env (dev/staging/prod), base URL, API keys, flavor...
│   ├── errors/                   # Exception custom & failure models: ServerException, CacheFailure...
│   ├── network/                  # Network layer: dio client, interceptors, connectivity checker...
│   ├── theme/                    # Theme toàn app: AppTheme, colors, text styles, dark/light mode
│   ├── utils/                    # Hàm tiện ích chung: date format, validators, logger, extensions helper...
│   
│
├── features/                     # Các module tính năng (feature-based, mỗi tính năng độc lập)
│   └── {feature-name}/           # Ví dụ: auth, home, profile, product, cart...
│       ├── data/                 # Layer Data – lấy & chuyển đổi dữ liệu từ nguồn ngoài
│       │   ├── datasources/      # Nguồn dữ liệu thực tế (remote + local)
│       │   │   ├── remote/       # Gọi API (REST, GraphQL...)
│       │   │   └── local/        # Local storage: Hive, SharedPreferences, Isar, SQLite...
│       │   ├── models/           # DTO / Model từ API (không phải entity business)
│       │   │   ├── request/      # Request body cho POST/PUT (LoginRequest, UpdateProfileRequest...)
│       │   │   └── response/     # Response từ API (UserResponse, ProductListResponse...)
│       │   └── repositories/     # Implementation concrete của Repository (kết nối data sources)
│       │
│       ├── domain/               # Layer Domain – business logic thuần, độc lập framework
│       │   ├── entities/         # Entity business chính (UserEntity, ProductEntity...)
│       │   ├── repositories/     # Abstract Repository (interface/contract)
│       │   └── usecases/         # UseCase – logic business cụ thể (LoginUseCase, GetProfileUseCase...)
│       │
│       └── presentation/         # Layer Presentation – UI + state (GetX)
│           ├── bindings/         # GetX Binding cho từng route/feature (inject controller + usecase...)
│           ├── controllers/      # GetX Controller: state, logic UI (LoginController, HomeController...)
│           ├── pages/            # Màn hình chính (full page): LoginPage, HomePage, ProfilePage...
│           └── widgets/          # Widget riêng tư của feature (không dùng chung): CustomCard, FeatureButton...
│
├── common/                       # Thành phần dùng chung toàn app (shared)
│   ├── widgets/                  # Widget chung: AppButton, LoadingWidget, CustomTextField, AppDialog...
│   └── extensions/               # Dart extensions: StringExt, WidgetExt, DateExt, NumExt...
│
├── app.dart                      # Widget gốc: GetMaterialApp (theme, initialRoute, getPages, locale...)
├── main.dart                     # Entry point: init dependencies, runApp(MyApp())
├── routes/                       # Quản lý routing toàn app (GetX)
└── l10n/                         # Quản lý ngôn ngữ toàn app (GetX)
```

## Architecture Principles
* **Separation of Concerns:** Aim for separation of concerns similar to MVC/MVVM, with defined Model, View, and ViewModel/Controller roles.
* **Logical Layers:** Organize the project into logical layers:
    * Presentation (widgets, screens)
    * Domain (business logic classes)
    * Data (model classes, API clients)
    * Core (shared classes, utilities, and extension types)
* **Feature-based Organization:** For larger projects, organize code by feature, where each feature has its own presentation, domain, and data subfolders. This improves navigability and scalability.

## State Management
* **Built-in Solutions:** Prefer Flutter's built-in state management solutions. Do not use a third-party package unless explicitly requested.
* **Streams:** Use `Streams` and `StreamBuilder` for handling a sequence of asynchronous events.
* **Futures:** Use `Futures` and `FutureBuilder` for handling a single asynchronous operation that will complete in the future.
* **ValueNotifier:** Use `ValueNotifier` with `ValueListenableBuilder` for simple, local state that involves a single value.

  ```dart
  // Define a ValueNotifier to hold the state.
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  // Use ValueListenableBuilder to listen and rebuild.
  ValueListenableBuilder<int>(
    valueListenable: _counter,
    builder: (context, value, child) {
      return Text('Count: $value');
    },
  );
    ```

* **ChangeNotifier:** For state that is more complex or shared across multiple widgets, use `ChangeNotifier`.
* **ListenableBuilder:** Use `ListenableBuilder` to listen to changes from a `ChangeNotifier` or other `Listenable`.
* **MVVM:** When a more robust solution is needed, structure the app using the Model-View-ViewModel (MVVM) pattern.
* **Dependency Injection:** Use simple manual constructor dependency injection to make a class's dependencies explicit in its API, and to manage dependencies between different layers of the application.
* **Provider:** If a dependency injection solution beyond manual constructor injection is explicitly requested, `provider` can be used to make services, repositories, or complex state objects available to the UI layer without tight coupling (note: this document generally defaults against third-party packages for state management unless explicitly requested).

## Data Flow
* **Data Structures:** Define data structures (classes) to represent the data used in the application.
* **Data Abstraction:** Abstract data sources (e.g., API calls, database operations) using Repositories/Services to promote testability.

## Routing
* **GoRouter:** Use the `go_router` package for declarative navigation, deep linking, and web support.
* **GoRouter Setup:** To use `go_router`, first add it to your `pubspec.yaml` using the `pub` tool's `add` command.

  ```dart
  // 1. Add the dependency
  // flutter pub add go_router

  // 2. Configure the router
  final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'details/:id', // Route with a path parameter
            builder: (context, state) {
              final String id = state.pathParameters['id']!;
              return DetailScreen(id: id);
            },
          ),
        ],
      ),
    ],
  );

  // 3. Use it in your MaterialApp
  MaterialApp.router(
    routerConfig: _router,
  );
  ```
* **Authentication Redirects:** Configure `go_router`'s `redirect` property to handle authentication flows, ensuring users are redirected to the login screen when unauthorized, and back to their intended destination after successful login.

* **Navigator:** Use the built-in `Navigator` for short-lived screens that do not need to be deep-linkable, such as dialogs or temporary views.

  ```dart
  // Push a new screen onto the stack
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const DetailsScreen()),
  );

  // Pop the current screen to go back
  Navigator.pop(context);
  ```
