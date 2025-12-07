# Example Usage

## Overview
This file shows you, how to use ``DGDeletableItem`` or ``SwiftUICore/View/onDelete(perform:)``. Both options returning the same result.

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
    @State private var items1: [DemoItem] = [
        DemoItem(title: "Buy milk"),
        DemoItem(title: "Write documentation"),
        DemoItem(title: "Refactor DeleteGesture demo")
    ]

    @State private var items2: [DemoItem] = [
        DemoItem(title: "Buy milk"),
        DemoItem(title: "Write documentation"),
        DemoItem(title: "Refactor DeleteGesture demo")
    ]

    var body: some View {
        NavigationStack {
            VStack{
                ForEach(items1) { item in
                    DGDeletableItem(onDelete: {     // This is option one to use the gesture
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
                ForEach(items2) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        Text("Swipe / delete")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onDelete{                      // This is option two to use the gesture
                        delete(item)
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
