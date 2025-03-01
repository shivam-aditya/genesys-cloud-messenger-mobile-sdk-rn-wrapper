# <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPNpoTfN7s-CudM4rAFGbjNSbwARRjiOdu0otHMK9tiYL8__ZhreOhPyO5QHSuRIrSvDo&usqp=CAU" height="50" style="margin-right:20px"/> genesys-cloud-messenger-mobileapp-wrapper

> Genesys Cloud Messaging SDK for React Native

The original SDK provides a simple react native wrapper for the Genesys Cloud Messenger SDK.
This version has updates to support the v1.7.0 of the messenger-mobile-sdk.

**Author:** Genesys, Shivam Aditya

**Platform Support:** Android, iOS

- [Getting Started](#getting-started)
  - [Pre-Requisites](#pre-requisites)
  - [Install](#install)
  - [Update](#update)
- [Platform specific additional steps](#platform-specific-additional-steps)
  - [Android](#android)
  - [iOS](#ios)
- [Usage](#usage)
  - [Import](#import)
  - [Start Chat](#start-chat)
  - [Chat Events](#chat-events)
- [Sample Application](https://github.com/genesys/MobileDxRNSample)
- [License](#license)

## Getting Started

### Pre-requisites

In order to use this SDK you need a Genesys account with the Messaging feature enabled.

### Install

Run the following on the application root directory.

- **Option 1 - `npm install`**

  ```sh
  npm install genesys-cloud-messenger-mobileapp-wrapper --save
  ```

- **Option 2 - `yarn add`**

  ```sh
  yarn add genesys-cloud-messenger-mobileapp-wrapper
  ```

- **Install Genesys chat module native dependency**
  ```sh
  react-native link genesys-cloud-messenger-mobileapp-wrapper
  ```

### Update

To update your project to the latest version of `genesys-cloud-messenger-mobileapp-wrapper`

```sh
npm update genesys-cloud-messenger-mobileapp-wrapper
```

## Platform specific additional steps

### android

In order to be able to use the chat module on android please follow the next steps.

1. Go to `build.gradle` file, on the android project of your react native app.
   ```cmd
   YourAppFolder
   ├── android
   │   ├── app
   │   │   ├── build.gradle
   │   │   ├── proguard-rules.pro
   │   │   └── src
   │   ├── build.gradle   <---
   │   ├── gradle
   │   │   └── wrapper
   │   ├── gradle.properties
   │   ├── gradlew
   │   ├── gradlew.bat
   │   └── settings.gradle
   |
   ```

- Add the following repositories:
  ```gradle
  mavenCentral()
  maven {
        url ("https://genesysdx.jfrog.io/artifactory/genesys-cloud-android.prod/")
    }
  ```

### ios

In order to be able to use the chat module on iOS please follow the next steps.

1. Go to `Podfile` file, on the ios project of your react native app.

   ```cmd
   YourAppFolder
   ├── ios
   │   ├── Podfile   <---
   ```

   - validate your platform is set to `iOS13` or above.

   ```ruby
   platform :ios, '13.0'
   ```

   - Add Genesys Messeging SDK sources.

   ```ruby
   source 'https://github.com/genesys/dx-sdk-specs-dev'
   source 'https://github.com/CocoaPods/Specs'
   ```

   - Add `use_frameworks!` inside `target` scope.
   - Add below `post_install` inside `target` scope.

   ```ruby
       target 'YourAppTargetName' do
       config = use_native_modules!
       use_frameworks!

       use_react_native!(
           :path => config[:reactNativePath],
           # to enable hermes on iOS, change `false` to `true` and then install pods
           :hermes_enabled => false
       )

       post_install do |installer|
           react_native_post_install(installer)

           installer.pods_project.targets.each do |target|
           target.build_configurations.each do |config|
               config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
           end

           if (target.name&.eql?('FBReactNativeSpec'))
               target.build_phases.each do |build_phase|
               if (build_phase.respond_to?(:name) && build_phase.name.eql?('[CP-User] Generate Specs'))
                   target.build_phases.move(build_phase, 0)
               end
               end
           end
           end
       end
       end
   ```

   > [Podfile Full Example](https://github.com/genesys/MobileDxRNSample/blob/master/ios/Podfile)

   - **Disable `Flipper` if activated.**

   ```ruby
        # use_flipper!()
   ```

   2 . Make sure you run `pod update genesys-cloud-messenger-mobileapp-wrapper` to get latest version.

## Usage

### import

Import `GenesysCloud` module.

```javascript
import { NativeModules } from "react-native";
const { GenesysCloud } = NativeModules;
```

### start-chat

Call `startChat` to get the messenging view and start conversation with an agent.

```javascript
// Start a chat using the following line:
GenesysCloud.startChat(deploymentId, domain, tokenStoreKey, logging);
```

### start-chat with custom attributes

Call `startChatWithCustomAttributes` to get the messenging view and start conversation with an agent with custom attributes.

```javascript
// Start a chat using the following line:
GenesysCloud.startChat(
  deploymentId,
  domain,
  tokenStoreKey,
  logging,
  customAttributes
);
```

Here customAttributes should be a Map / Dictionary of [String, String] attributes.

### chat-events

The wrapper allows listenning to events raised on the chat.

- Error events
  Error event has the following format: `{errorCode:"", reason:"", message:""}`

- State events
  Currently only `started` and `ended` are supported.
  State event has the following format: `{state:""}`

In order to register to chat events, add the following to your App:

```javascript
import { DeviceEventEmitter, NativeEventEmitter } from "react-native";

// Create event emitter to subscribe to chat events
const eventEmitter =
  Platform.OS === "android"
    ? DeviceEventEmitter
    : new NativeEventEmitter(GenesysCloud);

//-> Before calling to startChat, make sure to subscribe to chat events.

// Adds a listener to messenger chat errors.
listeners["onMessengerError"] = eventEmitter.addListener(
  "onMessengerError",
  (error) => {}
);

// Adds a listener to messenger chat state events.
listeners["onMessengerState"] = eventEmitter.addListener(
  "onMessengerState",
  (state) => {}
);

//-> Once the chat was ended, the listeners should be removed.
listeners["onMessengerError"].remove();
listeners["onMessengerState"].remove();

// E.g. Usage of the `ended` state event to remove chat listeners:
const onStateChanged = (state) => {
  if (state.state == "ended") {
    Object.keys(listeners).forEach((key) => {
      const listener = listeners[key];
      console.log(`removing listener: ${key}`);
      if (listener) listener.remove();
    });
  }
};
```

#### 👉 Checkout [Sample Application](https://github.com/genesys/MobileDxRNSample/blob/master/App.js) for more details

---

## Android

### Configure chat screen orientation

Before `startChat` is called, use `GenesysCloud.requestScreenOrientation()` API to set the chat orientation to one of the available options provided by `GenesysCloud.getConstants()`.

- SCREEN_ORIENTATION_PORTRAIT
- SCREEN_ORIENTATION_LANDSCAPE
- SCREEN_ORIENTATION_UNSPECIFIED
- SCREEN_ORIENTATION_LOCKED

```javascript
// E.g.
GenesysCloud.requestScreenOrientation(
  GenesysCloud.getConstants().SCREEN_ORIENTATION_LOCKED
);
```

### MinifyEnabled and proguard rules

If the hosting app is using the `minifyEnabled` on gradle configurations, the following line should be added to the `proguard-rules.pro` file:  
`-keep class com.genesys.cloud.messenger.transport.shyrka.** { *; }`

## License

MIT
