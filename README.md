# synTrack
<img align="right" alt="logo" src="./res/logo/syntrack_logo_s.png" />

Time Tracking and Booking tool built with Flutter to:

1) Search for Redmine Tasks
2) Track your time
3) Book
4) ???
5) Profit!

![showcase GIF](./doc/synTrack.gif)

## Development

### [Install Flutter](https://flutter.dev/docs/get-started/install)

### Get Packages
```bash
$ flutter pub get
```
### Run Code-Generator
Run once:
```bash
$ flutter pub run build_runner build --delete-conflicting-outputs
```
Watch:
```bash
$ flutter pub run build_runner watch --delete-conflicting-outputs
```

#### VSCode
You can run both commands above using **VSCode-Tasks**:
* `CTRL + SHIFT + P`
* Type: `Tasks Run Task`
* `Enter`
* Choose `gen:build_runner` or `gen:build_runner:watch`

### Enable Flutter for Desktop

```bash
$ flutter config --enable-windows-desktop
$ flutter config --enable-macos-desktop
$ flutter config --enable-linux-desktop
```
[Full Guide](https://flutter.dev/desktop)

### Run

```bash
$ flutter run -d linux
```

#### VSCode
Just select Linux as your device and launch the `syntrack` launch configuration.

### Compile
```bash
$ flutter build linux --release
```
