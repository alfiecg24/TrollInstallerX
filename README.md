<div align="center">
    <h1>TrollInstallerX</h1>
    <img src="Resources/Icon.png" width="125" height="125" />
</div>

## Overview
TrollInstallerX is a universal TrollStore installer. It focuses on being extremely reliable and easy to use. It is also very fast, being able to install TrollStore in a matter of seconds on the latest devices.

TrollInstallerX supports all devices running iOS 14.0 - 16.6.1, both arm64 and arm64e. It makes use of three different methods to install TrollStore, depending on what you choose. These methods are:
* **MacDirtyCow indirect installation**: using CVE-2022-46689, TrollInstallerX can overwrite a system application with TrollHelper, and then open that application for you to install TrollStore. The benefit of this method is that it has a 100% success rate, however, it does not allow for a direct installation of TrollStore straight from the installer.
  * Supports iOS 15.0 - 15.7.1, iOS 16.0 - 16.1.2.

* **kfd + dmaFail direct installation**: using the [kfd](https://github.com/felix-pb/kfd) kernel exploit, along with the [dmaFail](https://github.com/opa334/Dopamine/blob/2.x/Application/Dopamine/Exploits/dmaFail/dmaFail.c) PPL bypass on iOS 15.2+ arm64e devices, TrollInstallerX can install TrollStore directly onto the device without having to leave the installer. This is the easiest and fastest method, however, can be subject to exploit failures.
  * Supports iOS 14.0 - 16.6.1 (arm64) and iOS 14.0 - 16.5.1 (arm64e).
    * **Note**: A15, A16, and M2 devices on iOS 16.5.1 do not support this method.

* **kfd indirect installation**: Using the [kfd](https://github.com/felix-pb/kfd) kernel exploit, TrollInstallerX can overwrite a system application with TrollHelper, and then open that application for you to install TrollStore. This method only exists due to both the lack of a PPL bypass on iOS 16.6 and above, as well as the fact that dmaFail is non-functional on A15, A16, and M2 devices on iOS 16.5.1.
  * Supports iOS 16.5.1 - 16.6.1 (arm64e).
    * **Note**: This method is the only method that supports A15, A16, and M2 devices on iOS 16.5.1.

## Usage
TrollInstallerX is extremely easy to use. Simply download the latest release from the [Releases](https://github.com/alfiecg24/TrollInstallerX/releases) page, and sideload it using your preferred method. Once installed, open the app and press the "Install TrollStore" button. From there, TrollStore will be installed onto your device.

TrollInstallerX will automatically choose the best method for your device. However, in some cases, you may want to choose a specific method. To do this, simply open the settings view and select the method you want to use. Once you have selected the method, press the "Install TrollStore" button and TrollInstallerX will use the method you have chosen.

**Note**: certain builds of iOS (mainly pre-installed versions and certain beta versions) do not have public download links for TrollInstallerX to use to download the kernelcache and patchfind it. In these cases, you must either use the MacDirtyCow indirect installation method, manually supply the kernelcache yourself, or use the offline patchfinder option (which is much less reliable).

## FAQ
> Why am I stuck at "Exploiting kernel"?

This is a common issue with the kfd exploit. Simply reboot your device and try again.

> Why does pressing "Install TrollStore" open something in my browser?

On iOS 15.0 - 15.4.1 (arm64) and iOS 14.0 - 15.6.1 (arm64e), TrollStore can be installed via TrollHelperOTA - a 100% reliable and preferred installation method that doesn't require an app be sideloaded whatsoever.

If you would to use TrollInstallerX regardless to install TrollStore, however, there's an option to disable the redirect to TrollHelperOTA in TrollInstallerX's settings.

> Why can I not open/see TrollStore after a successful installation?

If you are on a version that supports direct installation of TrollStore, press the "refresh icon cache" button that appears at the end of a successful installation. If you're on iOS 16.6 - 16.6.1 on arm64e, you will have to install again and refresh app registrations from TrollHelper.

> Why is the offline patchfinder extremely unreliable?

The offline patchfinder is unreliable because it does not have access to the kernelcache to properly patchfind. This is why it is only used as a last resort.

> Why does TrollInstallerX not support iOS 17.0?

TrollInstallerX does not support iOS 17.0 because we do not have any public exploits for it. Once one releases, it will be integrated into TrollInstallerX.

## Building
TrollInstallerX is a regular Xcode project, but the project also contains a build script. To build it and produce an IPA, simply run the `build.sh` script in the root of the project. This will build the project and produce an IPA in the root of the project.

## Credits
TrollInstallerX wouldn't have been possible without the work of the following people:
* [opa334](https://x.com/opa334dev) for [Dopamine](https://github.com/opa334/Dopamine), the dmaFail exploit and the kernel patchfinder
* [felix-pb](https://github.com/felix-pb) for the kfd exploits
* [kok3shidoll](https://github.com/kok3shidoll) for lots of work on arm64 support for Dopamine
* [Kaspersky](https://securelist.com/operation-triangulation-the-last-hardware-mystery/111669/) for Operation Triangulation
* [wh1te4ever](https://github.com/wh1te4ever) for [kfund](https://github.com/wh1te4ever/kfund)
* [Zhuowei](https://github.com/zhuowei) for the tccd unsandboxing method
* [dhinakg](https://github.com/dhinakg) for the memory hogger and help with [libgrabkernel2](https://github.com/alfiecg24/libgrabkernel2)
* [staturnz](https://github.com/staturnzz) for work on the kernel patchfinder
* [aaronp613](https://x.com/aaronp613) for the TrollInstallerX icon
* [sourcelocation](https://github.com/sourcelocation) for the original Dopamine UI
