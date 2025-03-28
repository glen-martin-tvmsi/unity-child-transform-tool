using System.Collections;
using System.Collections.Generic;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using UnityEditor;

public class ChildTransformToolTests
{
    // Test position updates in local space
    [Test]
    public void PositionLocalSpaceTest()
    {
        // Create test objects
        var parent = new GameObject("TestParent");
        var child = new GameObject("TestChild");
        child.transform.parent = parent.transform;
        
        // Setup initial conditions
        child.transform.localPosition = new Vector3(1, 2, 3);
        
        // Create test window
        var window = ScriptableObject.CreateInstance<ChildTransformWindow>();
        window.parentTransform = parent.transform;
        
        // Set private fields via reflection
        var targetPositionField = typeof(ChildTransformWindow).GetField("targetPosition", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        targetPositionField.SetValue(window, new Vector3(5, 5, 5));
        
        var positionAxisMaskField = typeof(ChildTransformWindow).GetField("positionAxisMask", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        positionAxisMaskField.SetValue(window, new bool[] { true, false, true });
        
        var updatePositionField = typeof(ChildTransformWindow).GetField("updatePosition", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        updatePositionField.SetValue(window, true);
        
        // Use reflection to call private method
        var method = typeof(ChildTransformWindow).GetMethod("ApplyTransforms", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        method.Invoke(window, null);
        
        // Verify results
        Assert.AreEqual(5, child.transform.localPosition.x);
        Assert.AreEqual(2, child.transform.localPosition.y); // Unchanged
        Assert.AreEqual(5, child.transform.localPosition.z);
        
        // Cleanup
        Object.DestroyImmediate(parent);
    }
}
