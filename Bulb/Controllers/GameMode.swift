//
//  GameMode.swift
//  Bulb
//
//  Created by Николай Жирнов on 28.03.2025.
//

// Перечисление для режимов "Правда/Действие"
enum TruthOrDareMode: String, CaseIterable {
    case truth = "Правда"
    case dare = "Действие"
}

// Перечисление для режимов "Пальцы/Стрелка"
enum SelectionMode: String, CaseIterable {
    case wheel = "Колесо"
    case fingers = "Пальцы"
}
