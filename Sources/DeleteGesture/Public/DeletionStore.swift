//
//  Delete Item.swift
//  Hausaufgabenplaner
//
//  Created by Samuel Meincke on 11.11.25.
//
import Foundation

@available(iOS 17, macOS 14, *)
@available(tvOS, unavailable)
internal typealias DeletionStore = DGDeletionStore

@available(iOS 17, macOS 14, *)
@available(tvOS, unavailable)
@Observable
final public class DGDeletionStore{
    var displayedObject: UUID? = nil
}
