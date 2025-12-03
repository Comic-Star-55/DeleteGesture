//
//  PreferencKeys.swift
//  Hausaufgabenplaner
//
//  Created by Samuel Meincke on 23.05.25.
//
import SwiftUI

internal struct ViewHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

internal struct ViewWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
