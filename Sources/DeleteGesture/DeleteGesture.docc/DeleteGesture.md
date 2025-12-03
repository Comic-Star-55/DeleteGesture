# ``DeleteGesture``

A delete gesture you can use everywhere in SwiftUI.

## Overview

This package provides a delete gesture for iOS and macOS that you can use anywhere in SwiftUI.

Wherever you use this package, you must add a ``DGDeletionStore`` to the environment. For more information, see <doc:Example>.

This is the recommended setup in your `App`:

```swift
import SwiftUI
import DeleteGesture

@main
struct MyApp: App {
    @State private var deletionStore = DGDeletionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(deletionStore)
        }
    }
}
```

## Topics

- ``DGDeletableItem``
- ``DGDeletionStore``
