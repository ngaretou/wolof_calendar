# Calendrier Wolof

A companion app to the Wolof Calendar.

Track the Western and Wolof months together with Scripture passages in Roman script, Arabic script, and audio.

Web version at http://cal.sng.al


## What's new?

### 2.3.3 (2025 version)

- Added a 'go to today' button
- Fixed the Facebook Messenger launch delay
- Fixed initial theme was going light rather than dark b/c of an error with the asset cache deletion

### 2.3

- `ColorScheme.fromImageProvider` rather than `Palette Generator`
- Making some animations go faster - from one background to another & colorscheme change and the drawer open/close animation.

### 2.2

- New glass theme

### 2.4.0

- new data handling in chunks
- new qr code sharing
- revised theme coloring - now based on monthly image at app launch one time rather than changing with user scroll to new month. 
- revision to scripture drawer
- many refinements to UI and scrolling precision

### 2.4.2

- fix for three button nav problem 

## TODO
- new photo thanks


rm -rf build/web
flutter build web 
cd build/web
HASH=$( (cat main.dart.js; date +%s) | sha256sum | cut -c1-8 )
mv main.dart.js main.dart.$HASH.js
sed -i .bak "s/main.dart.js/main.dart.$HASH.js/g" flutter_bootstrap.js 
rm flutter_bootstrap.js.bak 
cd ../..