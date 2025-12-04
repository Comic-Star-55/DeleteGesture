//
//  Delete Item.swift
//  Hausaufgabenplaner
//
//  Created by Samuel Meincke on 11.11.25.
//
import Foundation

@available(iOS 17, macOS 14, *)
@available(tvOS, unavailable)
@Observable
final internal class DeletionStore{
    var displayedObject: UUID? = nil
    
    @MainActor static let shared = DeletionStore()
    
    public init() {}
}
