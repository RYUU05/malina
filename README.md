# Malina App

Небольшое Flutter-приложение для заказа еды и бьюти-услуг. Проект собран по feature-структуре и хранит пользовательское состояние локально, без внешнего backend.

## Что есть в приложении

- Авторизация с хранением текущего пользователя в `SharedPreferences`.
- Блокировка после трех неудачных попыток входа.
- Корзина с разделением по категориям и локальным сохранением.
- QR-сканер для быстрого добавления позиций.
- Экран избранного с отдельным репозиторием и BLoC.

## Технический стек

- Flutter
- flutter_bloc
- go_router
- get_it
- shared_preferences
- freezed / json_serializable
- mobile_scanner

## Запуск

1. `flutter pub get`
2. `dart run build_runner build`
3. `flutter run`

## Структура

- `lib/core` — DI, роутинг и общие инфраструктурные части.
- `lib/features/auth` — авторизация и состояние сессии.
- `lib/features/cart` — корзина, модели и локальное хранение.
- `lib/features/favorites` — избранное.
- `lib/features/home`, `profile`, `qr` — отдельные пользовательские экраны.
