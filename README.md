# 🚖 Дневник смен водителя (Driver Tracker)

Кроссплатформенное мобильное приложение на **Flutter (Android & iOS)** с бэкендом на **ASP.NET Core (.NET 10) + Entity Framework Core + PostgreSQL**, упакованным в **Docker**.

Архитектура клиентского приложения выстроена строго по методологии **Feature-Sliced Design (FSD)**.

---

## 📑 Содержание
1. [Функциональность](#-функциональность)
2. [Архитектура и структура проекта](#-архитектура-и-структура-проекта)
3. [Стек технологий и зависимости](#-стек-технологий-и-зависимости)
4. [Инструкция по запуску](#-инструкция-по-запуску)
   - [Вариант А: Запуск бэкенда в Docker Compose](#вариант-а-запуск-бэкенда-в-docker-compose)
   - [Вариант Б: Локальный запуск бэкенда](#вариант-б-локальный-запуск-бэкенда)
   - [Вариант В: Автономный Mock-режим Flutter](#вариант-в-автономный-mock-режим-flutter)
   - [Запуск Flutter приложения](#запуск-flutter-клиента)
5. [Тестирование](#-тестирование)
6. [Использование ИИ (Отчёт для анкеты)](#-использование-ии-отчёт-для-анкеты)

---

## ✨ Функциональность

- **Сводка за выбранный день**:
  - Общее число поездок;
  - Общая выручка («грязными»);
  - Удержанная комиссия сервиса;
  - Чистый доход **«на руки»** (Выручка − Комиссия);
  - Детальная разбивка по способам оплаты: сумма и количество поездок по карте и наличными.
- **Интерактивный список поездок**:
  - Карточки с временем начала и окончания, продолжительностью поездки в минутах, суммой, комиссией и итогом «на руки»;
  - Цветовая индикация способа оплаты (безналичный / наличный расчет).
- **Переключение смен и дней**:
  - Быстрое переключение стрелками `[<]` и `[>]`;
  - Встроенный календарь (Date Picker) для перехода к любой дате;
  - Индикатор текущего дня («Сегодня»).
- **Добавление поездки через API**:
  - Модальное окно добавления поездки;
  - Выбор времени начала и окончания;
  - Калькулятор комиссии сервиса (по умолчанию 15% с возможностью ручной корректировки);
  - Валидация входных данных: сумма $> 0$, окончание позже начала, комиссия $\ge 0$;
  - **Защита от дублей**: отклонение запроса (код `409 Conflict`) при совпадении уникального `id` или при повторной отправке поездки с идентичными параметрами (`start`, `end`, `amount`, `payment`).
- **Модуль авторизации водителя**:
  - Экран входа и регистрации водителя;
  - Кнопка быстрой подстановки тестового водителя (`driver@example.com` / `password123`);
  - Сохранение токена сессии в `flutter_secure_storage`;
  - Автоматическая передача токена через `AuthInterceptor` в Dio;
  - Экран профиля водителя с информацией об окружении и кнопкой выхода.

---

## 🏛 Архитектура и структура проекта

### Структура проекта (FSD)
```text
driver_tracker/
├── .env.example                      # Переменные окружения для Docker
├── .dockerignore                     # Исключения для сборки Docker
├── docker-compose.yml                # Docker Compose (Backend + PostgreSQL)
├── env/
│   ├── development.example.json      # Пример конфигурации клиента
│   └── development.json              # Активная конфигурация Flutter (API url, mock-флаг)
├── server/                           # ASP.NET Core Web API (.NET 10)
│   ├── Controllers/                  # TripsController, AuthController
│   ├── Data/                         # AppDbContext, DbInitializer (seed), Entities
│   ├── Models/                       # DTOs и контракты запросов/ответов
│   ├── Services/                     # Бизнес-логика, расчёт сводки, защита от дублей
│   ├── Dockerfile                    # Multi-stage сборка .NET 10
│   └── Program.cs                    # DI, CORS, автоматический seed БД
├── server_tests/                     # xUnit тесты бэкенда
│   ├── SummaryCalculationTests.cs    # Тесты расчёта сводки и «на руки»
│   └── DuplicateTripProtectionTests.cs # Тесты защиты от дублей и валидации
├── lib/                              # Flutter клиент
│   ├── common/                       # Переиспользуемый слой FSD
│   │   ├── api/                      # DioClient, AuthInterceptor, SessionManager, ApiConstants
│   │   ├── config/                   # AppConfig (загрузка из env)
│   │   ├── domain/model/             # UserSession
│   │   ├── navigation/               # AppRouter (GoRouter), AppScaffold, BottomNavBar
│   │   ├── storage/                  # SecureStorageService, StorageKeys
│   │   ├── ui/widgets/               # Buttons, ErrorScreen, FormFields, Skeletons, Modals
│   │   └── utils/bloc_error_handler/ # Маппинг ошибок сети и валидации в понятные сообщения
│   ├── feature/                      # Фичи по методологии FSD
│   │   ├── auth/                     # Модуль авторизации (Data, Domain, Presentation)
│   │   │   ├── data/                 # Datasource (remote + mock), DTOs, Repository
│   │   │   ├── domain/               # Model, Repository Interface
│   │   │   └── presentation/         # AuthBloc, EmailCubit, LoginAvailableCubit, PageCubit
│   │   ├── trips/                    # Модуль дневника смен водителя
│   │   │   ├── data/                 # Remote & Mock Datasource, DTOs, Repository
│   │   │   ├── domain/               # Trip, DailySummary, Repository Interface
│   │   │   └── presentation/         # TripsBloc, AddTripCubit, SummaryCard, TripCard, Dialog
│   │   └── profile/                  # Экран профиля водителя и настроек
│   └── startup/                      # Инициализация приложения и DI
│       ├── api/                      # AppInitializerApi
│       └── impl/                     # AppInitializerImpl
├── test/                             # Unit тесты Flutter
│   ├── trips_summary_test.dart       # Проверка эталонных данных (3900 / 585 / 3315)
│   └── duplicate_trip_protection_test.dart # Проверка валидации и блокировки дубликатов
└── main.dart                         # Точка входа Flutter приложения
```

---

## 🛠 Стек технологий и зависимости

### Клиент (Flutter)
- **State Management**: `flutter_bloc`, `bloc_concurrency` (с `restartable` и `droppable` трансформерами)
- **Навигация**: `go_router` (с поддержкой `ShellRoute`)
- **Сетевой клиент**: `dio`, `pretty_dio_logger`, `dio_cookie_manager`, `cookie_jar`
- **Безопасное хранилище**: `flutter_secure_storage`
- **Утилиты и UI**: `equatable`, `intl`, `flutter_svg`, `cupertino_icons`

### Сервер (Backend)
- **Платформа**: ASP.NET Core (.NET 10)
- **ORM**: Entity Framework Core 10 (`Npgsql.EntityFrameworkCore.PostgreSQL`, `Microsoft.EntityFrameworkCore.InMemory`)
- **База данных**: PostgreSQL 16 (в Docker)
- **Контейнеризация**: Docker & Docker Compose
- **Тесты**: xUnit

---

## 🚀 Инструкция по запуску

### Вариант А: Запуск бэкенда в Docker Compose (Рекомендуемый)
Для запуска полноценного стека (PostgreSQL + ASP.NET Core API):

1. Скопируйте файл переменных окружения:
   ```bash
   cp .env.example .env
   ```
2. Запустите контейнеры:
   ```bash
   docker compose up --build
   ```
   API будет доступно по адресу `http://localhost:8080`. База данных автоматически инициализируется и заполняется тестовыми поездками водителя.

---

### Вариант Б: Локальный запуск бэкенда (без Docker)
Если на машине установлен .NET SDK:
```bash
dotnet run --project server/DriverTracker.Api.csproj
```
*(При отсутствии PostgreSQL сервер автоматически задействует InMemory-хранилище)*.

---

### Вариант В: Автономный Mock-режим Flutter (без запуска бэкенда)
Flutter-клиент имеет встроенный полноценный Mock-источник данных, позволяющий проверять весь интерфейс и логику без запущенного бэкенда.
В файле `env/development.json` установите:
```json
{
  "apiBaseUrl": "http://localhost:8080/api",
  "useMock": true
}
```

---

### Запуск Flutter клиента
1. Установите зависимости:
   ```bash
   flutter pub get
   ```
2. Запустите приложение на подключенном устройстве или эмуляторе:
   ```bash
   flutter run
   ```

> **Примечание для Android эмулятора**: при обращении к бэкенду на хост-машине укажите `"apiBaseUrl": "http://10.0.2.2:8080/api"` в `env/development.json`.

---

## 🧪 Тестирование

Проект покрыт автоматическими тестами на обоих уровнях (бэкенд и мобильный клиент).

### 1. Тесты Flutter клиента
Проверяют расчёт эталонной сводки за день из ТЗ (3900 ₽ выручка, 585 ₽ комиссия, 3315 ₽ на руки), разбивку по типам оплаты, валидацию данных ($amount > 0$, $end > start$) и защиту от дублей:
```bash
flutter test
```
*Результат: 9 пройденных тестов (100% success).*

### 2. Тесты бэкенда (xUnit)
Проверяют работу сервиса поездок, подсчёт показателей и блокировку повторных отправок:
```bash
dotnet test server_tests/DriverTracker.Api.Tests.csproj
```
*Результат: 8 пройденных тестов (100% success).*

---

## 🤖 Использование ИИ (Отчёт для анкеты)

### Как использовался ИИ:
- Проектирование чистой архитектуры по методологии **Feature-Sliced Design (FSD)** для Flutter-клиента и REST API на ASP.NET Core;
- Генерация DTO-моделей, валидаторов и транзакционной логики защиты от повторных отправок поездок;
- Написание модульных тестов на проверку расчёта сводки и блокировки дубликатов;
- Создание Dockerfile и docker-compose конфигурации.

### Где ошибся ИИ:
1. **Глубина относительных путей в FSD**: Из-за глубокой вложенности файлов (например, `lib/feature/trips/presentation/logic/trips_bloc/trips_bloc.dart` — 5 уровней вложенности) относительные импорты вида `../../../../common/...` привели к ошибкам `uri_does_not_exist`.
2. **Изменение API Flutter 3.41**: В `ThemeData` свойство `cardTheme` в актуальной версии ожидает тип `CardThemeData`, а не устаревший класс `CardTheme`.
3. **Опечатка в generic-параметре BlocBuilder**: В одном из сгенерированных виджетов в тип закрался артефакт языка `BlocBuilder<AuthBloc, 状态: AuthState>`.

### Что исправил разработчик:
1. Заменил хрупкие глубокие относительные пути на канонические пакетные импорты `package:driver_tracker/...`, что полностью исключило ошибки разрешения путей.
2. Исправил конструктор темы на `CardThemeData` в соответствии с Flutter 3.41 API.
3. Исправил типографику и сигнатуру `BlocBuilder<AuthBloc, AuthState>` в форме регистрации.
4. Проверил и зафиксировал прохождение всех 17 тестов (9 во Flutter и 8 в .NET).
