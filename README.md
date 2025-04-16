# MotionOrientation
Notifies changes in device orientation using CoreMotion on iOS, sending updates through NotificationCenter.
It enables detection of device orientation and interface orientation while keeping the UI orientation locked, such as when the device is restricted to &#39;Portrait Orientation Lock&#39;. This makes it possible to respond to orientation changes even when the UI itself does not rotate.


## Requirements
This codes are under ARC.

These frameworks are needed.
<pre>
CoreMotion.framework
CoreGraphics.framework
</pre>


## Usage

### 1. Add this code before receive the orientation changes.
```swift
MotionOrientation.sharedInstance().start()
```

### 2. Then you can receive notifications from `NotificationCenter.default`

`MotionOrientationChangedNotification`, when the device orientation changed.
```swift
@objc private func deviceOrientationDidChange(notification: NSNotification) {
  // You can get it from userInfo with key kMotionOrientationDeviceOrientationKey
  if let userInfo = notification.userInfo,
     let rawValue = userInfo[kMotionOrientationDeviceOrientationKey] as? NSNumber,
     let orientation = UIDeviceOrientation(rawValue: rawValue.intValue) {
       print("new device orientation from userInfo: " + orientation)
  }

  // or get it from sharedInstance
  print("new device orientation from sharedInstance: " + MotionOrientation.sharedInstance().deviceOrientation);
}
```

`MotionOrientationInterfaceOrientationChangedNotification`, just when the interface orientation changed.
```swift
@objc private func interfaceOrientationDidChange(notification: NSNotification) {
  // You can get it from userInfo with key kMotionOrientationInterfaceOrientationKey
  if let userInfo = notification.userInfo,
     let rawValue = userInfo[kMotionOrientationInterfaceOrientationKey] as? NSNumber,
     let orientation = UIInterfaceOrientation(rawValue: rawValue.intValue) {
       print("new interface orientation from userInfo: " + orientation)
  }

  // or get it from sharedInstance
  print("new interface orientation from sharedInstance: " + MotionOrientation.sharedInstance().interfaceOrientation);
}
```

### 3. `MotionOrientation.sharedInstance()` always provides current orientations
```swift
private func printOrientations() {
  print("current device orientation: " + MotionOrientation.sharedInstance().deviceOrientation)
  print("current interface orientation: " + MotionOrientation.sharedInstance().interfaceOrientation)
}
```


## Energe Consumption Optimization

### Automatic stop and restart along the app life-cycle
1. will stop when the app **enters background**.
2. will restart when the app **becomes active**.

### Manual stop and restart
You can manually stop or restart it to save energe in specific situations.
```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    MotionOrientation.sharedInstance().start() // it's okay to call start repeatedly
}
```
```swift
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    MotionOrientation.sharedInstance().stop() // disables MotionOrientation until manually started
}
```


## Low Energy Mode

### Automatically
- turns on when `ProcessInfo.processInfo.isLowPowerModeEnabled`.
- turns on when `ProcessInfo.processInfo.thermalState` is NOT in (`.nominal`, `.fair`)

### Manually
You can manually turn on of off the Low Energe Mode.
```swift
MotionOrientation.sharedInstance().setLowEnergeModeForcely(true)
```