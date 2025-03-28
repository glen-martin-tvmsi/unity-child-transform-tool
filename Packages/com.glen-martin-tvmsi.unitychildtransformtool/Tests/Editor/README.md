# Unity Child Transform Tool Tests

This folder contains tests for the Unity Child Transform Tool.

## Running Tests

1. Open Unity and go to **Window > General > Test Runner**
2. Click on **EditMode** tab
3. Click **Run All** to execute all tests

## Available Tests

- **PositionLocalSpaceTest**: Tests updating child positions in local space
- **PositionWorldSpaceTest**: Tests updating child positions in world space
- **RotationTest**: Tests updating child rotations

## Adding New Tests

1. Add a new test method to the existing test class
2. Use the NUnit framework for assertions
3. Follow the pattern of existing tests for setting up game objects and tool windows
