# ``DGDeletionStore``

## Overview

A shared store that manages delete gestures for ``DGDeletableItem`` views.

Use ``DGDeletionStore`` as an environment object so that all ``DGDeletableItem`` instances in your view hierarchy can access and coordinate delete gestures. For examples, see <doc:Example>

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

Once the store is available in the environment, you can wrap any view in a ``DGDeletableItem`` to make it deletable.
