# ``SwiftUICore/View/onDelete(perform:)``
A simple way to use the delete gesture

## Overview

Use this function to apply the swipe-to-delete gesture to any [`View`](https://developer.apple.com/documentation/swiftui/view).

```swift
ForEach(items) { item in
    HStack {
        Text(item.title)
        Spacer()
        Text("Swipe / delete")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .onDelete{
        delete(item)
    }
}
```
> Note: You could use ``DGDeletableItem`` instead. Both returning the same result.
