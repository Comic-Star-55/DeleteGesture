# ``DeleteGesture``

A delete gesture you can use everywhere.

## Overview

This package provides a delete gesture for iOS and macOS. You can use it everywhere with SwiftUI.

Everywhere you use this Package, you have to add a ``DGDeletionStore`` as environment.

This is the recommended way:

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

## Topics

- ``DGDeletableItem``
- ``DGDeletionStore``
