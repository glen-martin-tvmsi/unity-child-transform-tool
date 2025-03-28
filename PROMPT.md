# Child Transform Tool - Product Requirements Document

## Overview
This document outlines the requirements for a Unity Editor Extension that allows users to batch-set transform properties (position, rotation, scale) of child GameObjects through a context menu.

## Technical Requirements and System Design

### 1. Context Menu Integration
- Add a menu item to the GameObject context menu
- Only show when right-clicking GameObjects with children
- Menu item text: "Set Children Transform"

### 2. Transform Parameter Input Interface
- Modal window for setting transform properties
- Toggle for selecting which properties to update (position, rotation, scale)
- Vector3 fields for each property
- Per-axis toggles for each property (X, Y, Z)
- Option to choose between world and local space

### 3. Transform Manipulation with Undo Support
- Update only selected axes for each transform property
- Support both world and local space transformations
- Register proper undo operations for each child
- Handle prefab instances correctly
- Warning for large hierarchies (>50 children)

## Implementation Roadmap

### Phase 1: Core Functionality
1. **Editor Script Foundation**
   - Context menu integration
   - Basic child iteration
   - Transform property setting

2. **Configuration Window**
   - Modal window with Vector3 inputs
   - Axis toggles
   - Space selection

3. **Undo/Redo Support**
   - Integration with Unity's undo stack
   - Error handling for prefab instances

### Phase 2: Enhanced Features
- **Recursive Child Processing**: Option to affect nested descendants
- **Preset System**: Save common transform configurations
- **Multi-Object Editing**: Apply to children across multiple selected parents

## Testing Protocol
- **Basic Functionality**: Verify transform changes for position, rotation, and scale
- **Axis Masking**: Confirm only selected axes are modified
- **Space Selection**: Test both local and world space transformations
- **Undo Operations**: Verify undo/redo correctly reverts/applies changes
- **Prefab Support**: Test with prefab instances
- **Performance**: Test with large hierarchies

## Conclusion
This Unity Editor Extension streamlines the process of batch-modifying transform properties of child GameObjects, saving time and reducing tedious manual adjustments for Unity developers.
