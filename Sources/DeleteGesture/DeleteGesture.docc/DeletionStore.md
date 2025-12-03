#  ``DGDeletionStore``

## Overview
This class is required for ``DGDeletableItem``

Use it as environment
```swift
import SwiftUI
import DeleteGesture

struct MyApp: App{
    @State private var deletionStore = DGDeletionStore()

    var body: some Scene{
        WindowGroup{
            ContentView()
                .environment(deletionStore)
        }
    }
}
```
