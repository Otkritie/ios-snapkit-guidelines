// Appearance.swift
// Copyright © PJSC Bank Otkritie. All rights reserved.

import UIKit

/// Протокол для основных числовых констант для верстки содержащий цвета, альфы и прочее
public protocol Appearance {}

/// Содержит основные базовые числовые константы
extension Appearance {
    /// Нулевой значение
    public var zero: Int { 0 }
}

/// Обертка для Appearance совместимых типов
public struct AppearanceWrapper<Base>: Appearance {
    private let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

/// Протокол описывающий которому должны конформить совместимы с Appearance типами
public protocol AppearanceCompatible: AnyObject {}

extension AppearanceCompatible {
    /// Предоставляет namespace обертку для Appearance совместимых типов.
    public var appearance: AppearanceWrapper<Self> { AppearanceWrapper(self) }
}

extension UIView: AppearanceCompatible {}
extension UIViewController: AppearanceCompatible {}
