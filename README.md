# Child Transform Tool

A Unity Editor Extension for batch-modifying transform properties (position, rotation, scale) of child GameObjects through a context menu.

## Features

- Batch-modify position, rotation, and scale of multiple child GameObjects at once
- Selectively modify specific axes (X, Y, Z) for each transform property
- Choose between local and world space for position and rotation modifications
- Full Undo/Redo support
- Prefab instance safety
- Performance warning for large hierarchies

## Usage

1. Select a GameObject with children in the hierarchy
2. Right-click and select **Set Children Transform** from the context menu
3. Configure which properties and axes to modify
4. Click **Apply**
