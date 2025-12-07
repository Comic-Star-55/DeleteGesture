//
//  View Modifier.swift
//  DeleteGesture
//
//  Created by Samuel Meincke on 07.12.25.
//
import SwiftUI

@available(macOS 15, iOS 18, *)
@available(visionOS, unavailable)
@available(tvOS, unavailable)
extension View{
    public func onDelete(perform action: @escaping () -> Void) -> some View {
        DGDeletableItem(onDelete: action, content: { self })
    }
}
