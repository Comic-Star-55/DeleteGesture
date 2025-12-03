# ``DGDeletableItem``

A SwiftUI view that enables delete gestures for any content.

## Overview

> Important: This view requires a ``DGDeletionStore`` in the environment.
> For more information, see <doc:Example>.

Use this view to add delete behavior to any SwiftUI view. Wrap your content in a ``DGDeletableItem`` and provide an `onDelete` closure that handles the deletion.

```swift
ForEach(items) { item in
    DGDeletableItem(onDelete: { deleteItem(item) }) {
        DetailView(for: item)
    }
}
```
