# DeleteGesture

A SwiftUI package that provides a flexible delete gesture you can use anywhere in your app — not limited to `List` or `Form`.

## Overview

**DeleteGesture** brings the familiar swipe-to-delete interaction to any SwiftUI view. Unlike the built-in `.onDelete` modifier, which only works within `List` or `Form`, this package lets you add delete gestures to any custom view hierarchy.

### Key Features

- 🔓 **Use Anywhere** — Not bound to `List` or `Form`. Add delete gestures to any view.
- 📱 **Cross-Platform** — Supports iOS (18+) and macOS (15+).
- 🎯 **Haptic Feedback** — Provides tactile feedback when crossing the delete threshold.
- 📖 **Fully Documented** — Includes comprehensive DocC documentation.

## Installation

Add DeleteGesture to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/Comic-Star-55/DeleteGesture.git", from: "1.0.0")
]
```

or using Xcode by adding `https://github.com/Comic-Star-55/DeleteGesture.git` under `File -> Add Package Dependencies...`

## Quick Start

### 1. Set Up the Deletion Store

Add a `DGDeletionStore` to your app's environment:

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

### 2. Wrap Views with DGDeletableItem

Use `DGDeletableItem` to make any view deletable:

```swift
import SwiftUI
import DeleteGesture

struct ContentView: View {
    @State private var items = ["Item 1", "Item 2", "Item 3"]

    var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                DGDeletableItem(onDelete: {
                    items.removeAll { $0 == item }
                }) {
                    Text(item)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}
```

## Documentation

This package includes comprehensive [DocC documentation](Sources/DeleteGesture/DeleteGesture.docc) covering:

- **DGDeletableItem** — The main view wrapper for adding delete gestures
- **DGDeletionStore** — The shared store for coordinating delete gestures
- **Example Usage** — Complete code examples showing integration patterns

To build the documentation locally, run:

```bash
swift package generate-documentation
```

## Use Case

Traditional SwiftUI delete gestures using `.onDelete` are restricted to `List` and `Form` views. This limitation makes it difficult to implement swipe-to-delete in:

- Custom card layouts
- Grid views
- Stacked views
- Any non-list UI patterns

**DeleteGesture** removes this restriction, allowing you to add intuitive delete interactions to any part of your SwiftUI interface.

## Requirements

- iOS 18.0+ / macOS 15.0+

## License

See the repository for license information.
