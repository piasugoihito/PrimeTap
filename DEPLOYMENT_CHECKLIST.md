# PrimeTap - Deployment Checklist

## Pre-Build Verification

- [x] All Dart files syntax verified
- [x] All imports present and correct
- [x] No circular dependencies
- [x] All asset references valid
- [x] Audio files mapped correctly
- [x] Data models consistent
- [x] State management properly implemented

## Build Steps

- [ ] Run `flutter pub get`
- [ ] Run `flutter analyze` (should show no errors)
- [ ] Run `flutter test` (if tests exist)
- [ ] Build for iOS: `flutter build ios`
- [ ] Build for Android: `flutter build apk` or `flutter build appbundle`

## Functional Testing

### Core Mechanics
- [ ] Tap on character increases points
- [ ] Tap speed increases with total taps
- [ ] Level increases every 200 taps (max 3)
- [ ] Coins earned = points × politician odds
- [ ] Coins display updates in real-time

### Gacha System
- [ ] Gacha button requires 100 coins
- [ ] Gacha spinning animation plays
- [ ] ~10% win rate for items
- [ ] Failed gacha refunds 50 coins
- [ ] Owned items appear in "取得済み" tab

### Unlock System
- [ ] Cannot unlock without 50 coins + Japan Lv3
- [ ] Unlock button shows correct status
- [ ] Unlocked politicians appear in list
- [ ] Selected politician can be changed

### Navigation
- [ ] All 4 tabs accessible
- [ ] Double-tap same tab returns to Training
- [ ] Tab switching plays menu SE
- [ ] Navigation state persists

### World Map
- [ ] Map scrolls infinitely (torus topology)
- [ ] All 8 country pins visible
- [ ] China pin at correct position
- [ ] Tap pin shows country politicians
- [ ] Unlock button works from map

### Audio
- [ ] BGM plays on startup
- [ ] BGM loops continuously
- [ ] Tap SE plays on character tap
- [ ] Invalid tap SE plays on non-character tap
- [ ] Menu SE plays on tab switch
- [ ] Gacha SE plays during gacha
- [ ] All SE volumes appropriate

### UI/UX
- [ ] Background animation visible on all screens
- [ ] AppBars transparent
- [ ] Screens transparent
- [ ] Character glow effect visible
- [ ] Scale animation on tap smooth
- [ ] Disclaimer multi-language switching works
- [ ] All text readable and properly formatted

### Data Persistence
- [ ] Game data saves after each tap
- [ ] Politician data persists across sessions
- [ ] User profile persists
- [ ] Items data persists

## Platform-Specific Testing

### iOS
- [ ] App launches without crash
- [ ] All permissions granted
- [ ] Audio works on device
- [ ] Haptic feedback (if implemented)
- [ ] Orientation handling correct

### Android
- [ ] App launches without crash
- [ ] All permissions granted
- [ ] Audio works on device
- [ ] Vibration works
- [ ] Orientation handling correct

## Performance Testing

- [ ] No frame drops during gameplay
- [ ] Memory usage stable
- [ ] No memory leaks
- [ ] Smooth scrolling on world map
- [ ] Quick loading times

## Release Preparation

- [ ] Version number updated
- [ ] Build number incremented
- [ ] App name correct
- [ ] Icon and splash screen finalized
- [ ] Privacy policy prepared
- [ ] Terms of service prepared
- [ ] Screenshots prepared for store

## Store Submission

### App Store (iOS)
- [ ] Bundle ID correct
- [ ] Signing certificate valid
- [ ] Provisioning profile valid
- [ ] Screenshots uploaded
- [ ] Description written
- [ ] Keywords set
- [ ] Rating questionnaire completed

### Google Play (Android)
- [ ] Package name correct
- [ ] Signing key configured
- [ ] Screenshots uploaded
- [ ] Description written
- [ ] Keywords set
- [ ] Content rating completed
- [ ] Privacy policy linked

## Post-Launch

- [ ] Monitor crash reports
- [ ] Check user reviews
- [ ] Monitor performance metrics
- [ ] Plan for updates
- [ ] Prepare hot fixes if needed

---

**Last Updated:** 2024-04-23
**Status:** Ready for deployment
