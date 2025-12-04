# Example Usage

## Overview
This file shows you, how to use ``DGDeletableItem`` 

## Examples

```swift
struct DemoItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
}
```

```swift
import SwiftUI
import DeleteGesture

struct ContentView: View {
    @State private var items: [DemoItem] = [
        DemoItem(title: "Buy milk"),
        DemoItem(title: "Write documentation"),
        DemoItem(title: "Refactor DeleteGesture demo")
    ]

    var body: some View {
        NavigationStack {
            ForEach(items) { item in
                DGDeletableItem(onDelete: {
                    delete(item)
                }) {
                    HStack {
                        Text(item.title)
                        Spacer()
                        Text("Swipe / delete")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("DeleteGesture Demo")
        }
    }

    private func delete(_ item: DemoItem) {
        guard let index = items.firstIndex(of: item) else { return }
        items.remove(at: index)
    }
}
```
