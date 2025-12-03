#  ``DGDeletableItem``
View to use in SwiftUI

## Overview

> Important: This view requires an ``DGDeletionStore`` as environment.
> For more Information: ``DeleteGesture``

Use this View to add the deletable ability to any View

```swift
ForEach(items){item in
    DeletableItem(onDelete: {deletItem(item)}){
        DetailView(for: Item)
    }
}
```
