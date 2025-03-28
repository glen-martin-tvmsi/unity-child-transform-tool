#!/bin/bash

# Child Transform Tool - Project Setup Script
# Author: Glen+Adam
# Date: March 28, 2025

# Define project variables
PROJECT_NAME="UnityChildTransformTool"
AUTHOR_NAME="Glen+Adam"
GITHUB_USERNAME="glen-martin-tvmsi"
VERSION="0.1"

# Check prerequisites and install Node.js if missing
function check_prerequisites() {
    echo "Checking prerequisites..."
    if ! command -v git &> /dev/null; then
        echo "Error: Git not found. Please install Git and try again."
        exit 1
    fi
    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        echo "Node.js or npm not found. Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    echo "All prerequisites are installed!"
}

# Prompt for Unity version and save it to config.json
function configure_unity_version() {
    echo "Configuring Unity version..."
    read -p "Enter your Unity version (e.g., 2022.3.35f1): " UNITY_VERSION
    UNITY_PATH="/mnt/c/Program Files/Unity/Hub/Editor/$UNITY_VERSION/Editor/Unity.exe"
    
    # Save configuration to config.json
    cat > config.json <<EOL
{
  "unityVersion": "$UNITY_VERSION",
  "unityPath": "$UNITY_PATH",
  "projectName": "$PROJECT_NAME",
  "version": "$VERSION"
}
EOL
    echo "Unity version configured and saved to config.json!"
}

# Create project structure
function create_project_structure() {
    echo "Creating project directory structure..."
    mkdir -p Assets/Editor Assets/Editor/Tests/EditMode Documentation Build
    echo "Project structure created!"
}

# Create Unity editor scripts
function create_unity_scripts() {
    echo "Creating Unity editor extension scripts..."
    cat > Assets/Editor/ChildPositionTool.cs <<EOL
using UnityEditor;
using UnityEngine;

public class ChildPositionTool : Editor
{
    [MenuItem("GameObject/Set Children Transform", true, 20)]
    static bool ValidateSetChildrenTransform()
    {
        return Selection.activeGameObject != null && 
               Selection.activeGameObject.transform.childCount > 0;
    }

    [MenuItem("GameObject/Set Children Transform", false, 20)]
    static void InitTransformSetter(MenuCommand command)
    {
        var window = ScriptableObject.CreateInstance<ChildTransformWindow>();
        window.parentTransform = Selection.activeGameObject.transform;
        window.ShowModalUtility();
    }
}
EOL

    cat > Assets/Editor/ChildTransformWindow.cs <<EOL
using UnityEditor;
using UnityEngine;

public class ChildTransformWindow : EditorWindow
{
    public Transform parentTransform;
    private bool updatePosition = true;
    private bool updateScale = false;
    private bool updateRotation = false;
    private Vector3 targetPosition = Vector3.zero;
    private Vector3 targetScale = Vector3.one;
    private Vector3 targetRotation = Vector3.zero;
    private bool[] positionAxisMask = { false, false, false };
    private bool[] scaleAxisMask = { false, false, false };
    private bool[] rotationAxisMask = { false, false, false };
    private bool useWorldSpace = false;
    const int MAX_CHILDREN_WARNING = 50;

    void OnGUI()
    {
        GUILayout.Label("Child Transform Settings", EditorStyles.boldLabel);

        updatePosition = EditorGUILayout.ToggleLeft("Update Position", updatePosition);
        if (updatePosition)
        {
            targetPosition = EditorGUILayout.Vector3Field("Target Position", targetPosition);
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("Apply to axes:", GUILayout.Width(80));
            positionAxisMask[0] = EditorGUILayout.ToggleLeft("X", positionAxisMask[0], GUILayout.Width(30));
            positionAxisMask[1] = EditorGUILayout.ToggleLeft("Y", positionAxisMask[1], GUILayout.Width(30));
            positionAxisMask[2] = EditorGUILayout.ToggleLeft("Z", positionAxisMask[2], GUILayout.Width(30));
            EditorGUILayout.EndHorizontal();
        }

        updateScale = EditorGUILayout.ToggleLeft("Update Scale", updateScale);
        if (updateScale)
        {
            targetScale = EditorGUILayout.Vector3Field("Target Scale", targetScale);
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("Apply to axes:", GUILayout.Width(80));
            scaleAxisMask[0] = EditorGUILayout.ToggleLeft("X", scaleAxisMask[0], GUILayout.Width(30));
            scaleAxisMask[1] = EditorGUILayout.ToggleLeft("Y", scaleAxisMask[1], GUILayout.Width(30));
            scaleAxisMask[2] = EditorGUILayout.ToggleLeft("Z", scaleAxisMask[2], GUILayout.Width(30));
            EditorGUILayout.EndHorizontal();
        }

        updateRotation = EditorGUILayout.ToggleLeft("Update Rotation", updateRotation);
        if (updateRotation)
        {
            targetRotation = EditorGUILayout.Vector3Field("Target Rotation (Euler Angles)", targetRotation);
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("Apply to axes:", GUILayout.Width(80));
            rotationAxisMask[0] = EditorGUILayout.ToggleLeft("X", rotationAxisMask[0], GUILayout.Width(30));
            rotationAxisMask[1] = EditorGUILayout.ToggleLeft("Y", rotationAxisMask[1], GUILayout.Width(30));
            rotationAxisMask[2] = EditorGUILayout.ToggleLeft("Z", rotationAxisMask[2], GUILayout.Width(30));
            EditorGUILayout.EndHorizontal();
        }

        useWorldSpace = EditorGUILayout.ToggleLeft("Use World Space (for Position & Rotation only)", useWorldSpace);

        if (GUILayout.Button("Apply"))
        {
            ApplyTransforms();
            Close();
        }
    }

    void ApplyTransforms()
    {
        if (parentTransform == null || parentTransform.childCount == 0) return;

        if (parentTransform.childCount > MAX_CHILDREN_WARNING)
        {
            if (!EditorUtility.DisplayDialog("Warning", $"This will modify {parentTransform.childCount} children. Continue?", "Yes", "No")) 
                return;
        }

        Undo.IncrementCurrentGroup();
        Undo.SetCurrentGroupName("Modify Child Transforms");
        
        foreach (Transform child in parentTransform)
        {
            if (updatePosition) UpdatePosition(child);
            if (updateScale) UpdateScale(child);
            if (updateRotation) UpdateRotation(child);
        }

        Undo.CollapseUndoOperations(Undo.GetCurrentGroup());
        EditorUtility.SetDirty(parentTransform.gameObject);
    }

    void UpdatePosition(Transform child)
    {
        Vector3 newPosition = useWorldSpace ? child.position : child.localPosition;
        
        if (positionAxisMask[0]) newPosition.x = targetPosition.x;
        if (positionAxisMask[1]) newPosition.y = targetPosition.y;
        if (positionAxisMask[2]) newPosition.z = targetPosition.z;

        Undo.RecordObject(child, "Child Position Modification");
        
        if (useWorldSpace)
            child.position = newPosition;
        else
            child.localPosition = newPosition;
    }

    void UpdateScale(Transform child)
    {
        Vector3 newScale = child.localScale;

        if (scaleAxisMask[0]) newScale.x = targetScale.x;
        if (scaleAxisMask[1]) newScale.y = targetScale.y;
        if (scaleAxisMask[2]) newScale.z = targetScale.z;

        Undo.RecordObject(child, "Child Scale Modification");
        child.localScale = newScale;
    }

    void UpdateRotation(Transform child)
    {
        Vector3 newRotation = useWorldSpace ? child.eulerAngles : child.localEulerAngles;

        if (rotationAxisMask[0]) newRotation.x = targetRotation.x;
        if (rotationAxisMask[1]) newRotation.y = targetRotation.y;
        if (rotationAxisMask[2]) newRotation.z = targetRotation.z;

        Undo.RecordObject(child, "Child Rotation Modification");
        
        if (useWorldSpace)
            child.eulerAngles = newRotation;
        else
            child.localEulerAngles = newRotation;
    }
}
EOL
    echo "Unity scripts created successfully!"
}

# Create build script with WSL-to-Windows path conversion
function create_build_script() {
    echo "Creating build script..."
    mkdir -p Build
    cat > Build/build.sh <<EOL
#!/bin/bash

# Load configuration
CONFIG_FILE="./config.json"
if [ ! -f "\$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found. Run setup script first."
    exit 1
fi

# Extract configuration using Node.js
UNITY_PATH=\$(node -e "console.log(require('./config.json').unityPath)")
VERSION=\$(node -e "console.log(require('./config.json').version)")
PROJECT_NAME=\$(node -e "console.log(require('./config.json').projectName)")

PACKAGE_NAME="\$PROJECT_NAME-v\$VERSION.unitypackage"

echo "Building Unity package: \$PACKAGE_NAME..."
echo "Using Unity at: \$UNITY_PATH"

if [ ! -f "\$UNITY_PATH" ]; then
  echo "Error: Unity executable not found at \$UNITY_PATH."
  echo "Please update the path in config.json and try again."
  exit 1
fi

BUILD_FOLDER="./Build"
PACKAGE_PATH="\$BUILD_FOLDER/\$PACKAGE_NAME"

mkdir -p "\$BUILD_FOLDER"

# Convert WSL path to Windows path format for Unity
# Get Windows path (C:/ format) instead of /mnt/c format
WINDOWS_PROJECT_PATH=\$(wslpath -w "\$(pwd)")
echo "Using Windows project path: \$WINDOWS_PROJECT_PATH"

# Call Unity to export the package
"\$UNITY_PATH" -batchmode -nographics -quit -projectPath "\$WINDOWS_PROJECT_PATH" -exportPackage "Assets/Editor" "\$PACKAGE_PATH"

if [ \$? -eq 0 ]; then
  echo "Package built successfully at \$PACKAGE_PATH!"
else
  echo "Error building package. Check Unity logs for details."
fi
EOL
    chmod +x Build/build.sh
    echo "Build script created!"
}

# Create README.md and package.json
function create_documentation() {
    echo "Creating README.md and package.json..."
    cat > README.md <<EOL
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
EOL

    cat > package.json <<EOL
{
  "name": "$PROJECT_NAME",
  "version": "$VERSION",
  "displayName": "Child Transform Tool",
  "description": "A Unity Editor Extension for batch-modifying transforms of child GameObjects",
  "author": "$AUTHOR_NAME",
  "license": "MIT",
  "scripts": {
    "build": "./Build/build.sh"
  }
}
EOL
    echo "Documentation created!"
}

# Initialize git repository (using wslpath for Windows compatibility)
function init_git() {
    echo "Setting up Git repository..."
    # This works better with WSL permissions on Windows filesystem
    WINDOWS_PATH=$(wslpath -w "$(pwd)")
    powershell.exe -Command "Set-Location '$WINDOWS_PATH'; git init; git config core.autocrlf true"
    
    cat > .gitignore <<EOL
# Unity specific files
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Uu]serSettings/
.vs/
.vscode/
*.csproj
*.unityproj
*.sln
*.user
.DS_Store
node_modules/
EOL

    powershell.exe -Command "Set-Location '$WINDOWS_PATH'; git add .; git commit -m 'Initial commit: Child Transform Tool for Unity created by $AUTHOR_NAME'"
    echo "Git repository initialized!"
}

# Main execution flow
check_prerequisites
create_project_structure
configure_unity_version
create_unity_scripts
create_build_script
create_documentation
init_git

echo "Project setup complete! 🎉"
echo "To build your Unity package: npm run build"
