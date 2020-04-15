# Что такое SnapKit:

**SnapKit** - это DSL обертка над Auto Layout, которая позволяет верстать вьюхи кодом, без xib'ов и storyboard'ов.
**Подробнее [здесь](https://github.com/SnapKit/SnapKit) и [здесь](http://snapkit.io/docs/).**

**Плюсы данного подхода:**
- Быстрота и чистота написания UIView
- Никаких конфликтов в nib файлах при слиянии веток в git
- Возможность проводить code-review (а не смотреть на автогенерированный xml файл) 
- Отказ от magic numbers constraints в пользу grid
- Легче переиспользовать элементы
- Все в одном месте: не нужно постоянно переключаться между storyboard'ом и кодом для конфигурации элемента

# Главное из примера (см. ниже):

- Протокол **[Grid](Sources/Grid.swift)** с **private extension**, где находятся все базовые значения отступов, а также, если нужно, кастомные отступы (например: space22)
- Протокол **[Appearance](Sources/Appearance.swift)** с **private extension**, где находятся различные magic numbers и кастомные шрифты/цвета, которые не нужно добавлять глобально. В общем всё, что касается **UI** конретной view
- Структура **Constants** с **private extension**, где находятся числовые и текстовые константы
- UI элементы вынесены визуально в отдельную блок сверху класса
- UI элементы иницилизируются и конфигурируются красиво с [**Then**](https://github.com/devxoul/Then), желательно через **lazy computed property**
- Есть две **раздельные** функции **addSubviews()** и **makeConstraints()**
- В функции **addSubviews()** добавление дочерних вьюшек происходит в [**иерархичном виде**](Sources/UIView%2BAdd.swift)

# Пример обычной UIView:

```swift

// MARK: - Grid

private extension Grid {
    /// heightRow
    var space60: CGFloat { 60 }
    /// Верхний отступ emailTextField
    var space22: CGFloat { 22 }
    /// Высота loginButton
    var space55: CGFloat { 55 }
}

// MARK: - Appearance

private extension Appearance {
    var animationDuration: Double { 0.1 }
    var parallaxValue: CGFloat { 10 }
    var alphaContainerView: CGFloat { 0.5 }
    var borderColor: UIColor { .customColor }
    var customFont: UIFont { .customFont }
    var buttonCornerRadius: CGFloat { 10 }
}

// MARK: - Constants

private extension Constants {
    static let emailPlaceholder = "Введите e-mail"
    static let textCharatersLimit = 140
}

/// Экран логина с использованеим email и password
final class LoginView: UIView {
       
    // MARK: - Private Properties
    
    private lazy var emailTextField = UITextField().then {
        $0.textContentType = .emailAddress
        $0.keyboardType = .emailAddress
        $0.placeholder = Constants.emailPlaceholder
    }
    
    private lazy var passwordTextField = UITextField().then {
        $0.keyboardType = .password
        $0.borderColor = appearance.borderColor
    }
    
    private lazy var loginButton = UIButton().then {
        $0.backgroundColor = .scDeepBlush
        $0.cornerRadius = appearance.buttonCornerRadius
    }
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // MARK: - Private Methods

    private func commonInit() {
        setupStyle()
        addSubviews()
        makeConstraints()
    }
    
    private func setupStyle() {
        backgroundColor = .white
    }
    
    private func addSubviews() {
        add { 
            contentView.add {
                emailTextField
                passwordTextField
                loginButton
            }
        }
    }
    
    private func makeConstraints() {
        contentView.snp.makeConstraints { make in
           make.edges.equalToSuperview().inset(grid.space16)
        }
        
        emailTextField.snp.makeConstraints { make in
           make.top.equalToSuperview().inset(grid.space22)
           make.leading.trailing.equalToSuperview().inset(grid.space16)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(grid.space16)
        }
        
        loginButton.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview().inset(grid.space8)
            make.height.equalTo(grid.space55)
        }
    }
    
}

```

# Советы и правила по верстке с помощью SnapKit:

**1. Пишем leading и trailing, вместо left и right**

**2. Описываем констреинты в приоритетном порядке: вертикаль (сверху вниз), горизонталь (слева направо), размер**

```
top, bottom, centerY, leading, trailing, centerX, width, height, size
```

**3. Все похожие отступы обьединяем вместе**

✅ Правильно
```swift
make.top.leading.trailing.equalToSuperView().inset(grid.space16)

```
❌ Неправильно
```swift
make.top.equalToSuperView().inset(grid.space16)
make.leading.equalToSuperView().inset(grid.space16)
make.trailing.equalToSuperView().inset(grid.space16)
```

**4. В любой непонятной ситуации используем inset**

✅ Исключение: Если это отступ между двумя элементами: leading к trailing. bottom к top

**5. Используем наиболее краткую запись: edges**

✅ Правильно
```swift
make.edges.equalToSuperView()
```

❌ Неправильно
```swift
make.top.bottom.leading.trailing.equalToSuperView()
```

**5. Используем наиболее краткую запись: center**

✅ Правильно
```swift
make.center.equalToSuperView()
```

❌ Неправильно
```swift
make.centerX.centerY.equalToSuperView()
```

**6. Используем наиболее краткую запись: size**

✅ Правильно
```swift
make.size.equalTo(grid.size50)
```

❌ Неправильно
```swift
make.width.height.equalTo(grid.size50)
```

**7. Родительские вьюшки не должны ничего знать о констреинтах дочерних вьюшек:**

✅ Правильно
```swift
rootView.addSubview(childView)
...
childView.snp.makeConstraints { make in
    make.centerX.equalToSuperview()
}

```

❌ Неправильно
```swift
rootView.addSubview(childView)
...
rootView.snp.makeConstraints { make in
    make.centerX.equalTo(childView)
}
```
