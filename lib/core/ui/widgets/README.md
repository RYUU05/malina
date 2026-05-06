# UI-компоненты для боковой панели и нижней навигации

## Содержание

### 1. `category_sidebar.dart`
Компонент для боковой плавающей панели категорий, расположенной справа от экрана.

#### Компоненты:
- `CategorySidebar` — основной виджет боковой панели
- `CategoryItem` — модель данных для категории
- `ScaffoldWithCategorySidebar` — обёртка для удобного размещения панели + контента

#### Свойства CategoryItem:
```dart
CategoryItem(
  id: 'food',           // Уникальный идентификатор
  label: 'Еда',         // Текст под иконкой
  icon: Icons.restaurant,  // Иконка
  count: 0,             // Счётчик в бейдже (0 = без бейджа)
  isSelected: false,    // Активна ли категория
  onTap: () {},         // Обработчик тапа
)
```

#### Особенности:
✓ Карточки 64×64px со скруглёнными углами
✓ Светло-серый фон (Colors.grey.shade100)
✓ Красный бейдж-счётчик в правом верхнем углу (если count > 0)
✓ Выбранная категория выделяется красной рамкой
✓ Текст под иконкой размер 10pt
✓ Расположена справа через Positioned: right: 0

---

### 2. `custom_bottom_nav_bar.dart`
Кастомный нижний TabBar с центральной плавающей красной кнопкой.

#### Компоненты:
- `CustomBottomNavBar` — основной виджет навигации (гибкий)
- `MalinaBottomNavBar` — готовый компонент для Malina (5 пунктов)
- `BottomNavItem` — модель для элемента навигации

#### Пункты (MalinaBottomNavBar):
1. **Лента** (feed icon)
2. **Избранное** (favorite_border icon)
3. **[Центральная плавающая кнопка]** (красная, круглая, icon: Icons.apps)
4. **Профиль** (person_outline icon)
5. **Корзина** (shopping_cart_outlined icon)

#### Особенности:
✓ Центральная кнопка диаметром 56px
✓ Красная с тенью (Color(0xFFF62C5B))
✓ НЕ модальное окно, встроено в scaffold
✓ Каждый пункт можно активировать
✓ Безопасный отступ снизу для iPhone (notch)

---

### 3. `example_screen_with_sidebar.dart`
Пример полного экрана с панелью и навигацией.

---

## Примеры использования

### Вариант 1: Использование `ScaffoldWithCategorySidebar` (рекомендуется)

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  String _selectedCategory = 'food';
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithCategorySidebar(
      appBar: AppBar(title: const Text('Моя страница')),
      categories: [
        CategoryItem(
          id: 'food',
          label: 'Еда',
          icon: Icons.restaurant,
          isSelected: _selectedCategory == 'food',
          onTap: () => setState(() => _selectedCategory = 'food'),
        ),
        CategoryItem(
          id: 'beauty',
          label: 'Бьюти',
          icon: Icons.spa,
          count: 3,  // Покажет бейдж с цифрой 3
          isSelected: _selectedCategory == 'beauty',
          onTap: () => setState(() => _selectedCategory = 'beauty'),
        ),
      ],
      child: ListView(
        children: [
          // Любой контент
          Text('Контент: $_selectedCategory'),
        ],
      ),
      bottomNavigationBar: MalinaBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onItemTapped: (index) => setState(() => _selectedNavIndex = index),
        onCenterPressed: () => print('Центральная кнопка нажата'),
      ),
    );
  }
}
```

### Вариант 2: Использование компонентов отдельно

```dart
class MyCustomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кастомная страница')),
      body: Stack(
        children: [
          // Основной контент
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Основной контент'),
            ),
          ),
          // Боковая панель
          CategorySidebar(
            categories: [
              CategoryItem(
                id: 'cat1',
                label: 'Категория 1',
                icon: Icons.category,
                onTap: () {},
              ),
            ],
            padding: EdgeInsets.only(top: 20, right: 12),
          ),
        ],
      ),
      bottomNavigationBar: MalinaBottomNavBar(
        selectedIndex: 0,
        onItemTapped: (index) {},
      ),
    );
  }
}
```

---

## Кастомизация

### Изменение цветов

```dart
CustomBottomNavBar(
  items: [...],
  activeColor: Color(0xFFF62C5B),      // Цвет активного элемента
  inactiveColor: Color(0xFF999999),    // Цвет неактивного
  backgroundColor: Colors.white,       // Фон навигации
)
```

### Позиция боковой панели

```dart
CategorySidebar(
  categories: [...],
  padding: EdgeInsets.only(
    top: 100,      // Отступ сверху
    right: 12,     // Отступ справа
  ),
)
```

### Кастомный значок центральной кнопки

```dart
// В CustomBottomNavBar измените Icons.apps на нужный вам icon
Container(
  // ...
  child: Icon(Icons.grid_view, color: Colors.white),
)
```

---

## Структура файлов

```
lib/core/ui/widgets/
├── category_sidebar.dart          # Боковая панель
├── custom_bottom_nav_bar.dart      # Нижняя навигация
├── example_screen_with_sidebar.dart # Пример использования
└── README.md                       # Этот файл
```

---

## API Сумма

### CategorySidebar
```dart
CategorySidebar({
  required List<CategoryItem> categories,
  EdgeInsets padding = const EdgeInsets.only(top: 20, right: 12),
})
```

### CustomBottomNavBar
```dart
CustomBottomNavBar({
  required List<BottomNavItem> items,
  VoidCallback? onCenterButtonPressed,
  Color activeColor = const Color(0xFFF62C5B),
  Color inactiveColor = const Color(0xFF999999),
  Color backgroundColor = Colors.white,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12),
})
```

### MalinaBottomNavBar
```dart
MalinaBottomNavBar({
  required int selectedIndex,
  required ValueChanged<int> onItemTapped,
  VoidCallback? onCenterPressed,
})
```

---

## Требования разработки

- Flutter 2.10+
- Material 3 (опционально)
- Dart 2.17+

---

## Версия

v1.0 - Начальная версия с базовым функционалом
