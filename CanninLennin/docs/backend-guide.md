# Backend guide

## Attention!!!

### This is a guide with examples on how to use the backend for the app

# 🚦 Parking Data Service — Usage Guide (Frontend)

You do **not** interact with JSON files directly.

You only interact with:

```swift
RestrictionService.shared
```

This acts like an internal backend running inside the iOS app.

---

## ✅ 1. Load data once (on app start or when opening the map)

```swift
RestrictionService.shared.load()
```

This loads:

- `Parking.geojson` → restriction poles (pins)
- `gdouble.json` → street segments (polylines)

> ⚠️ If you don't call this once, no data will be available.

---

## ✅ 2. Get nearby restrictions (to display pins)

Use this when the map moves or user location updates:

```swift
let restrictions = RestrictionService.shared.getRestrictions(
    near: CLLocationCoordinate2D(latitude: lat, longitude: lon),
    maxDistance: 150 // meters
)
```

Each result contains:

```swift
Restriction {
    panneauId: Int
    poleId: Int
    description: String
    code: String
    coordinate: CLLocationCoordinate2D
}
```

Example UI usage:

```swift
restrictions.forEach { restriction in
    map.addMarker(
        at: restriction.coordinate,
        title: restriction.code,
        subtitle: restriction.description
    )
}
```

---

## ✅ 3. Get nearest restriction (for taps on the map)

```swift
if let restriction = RestrictionService.shared.getNearestRestriction(
    to: tappedCoordinate
) {
    print("Closest restriction:", restriction)
}
```

Used for:
- User taps the map → show nearest restriction info
- "Can I park here?" feature

---

## ✅ 4. Get street segment linked to a restriction (polyline)

If you have a restriction and want to highlight the street:

```swift
if let segment = RestrictionService.shared.getStreetSegment(
    id: restriction.streetSegmentId
) {
    drawPolyline(segment.coordinates)
}
```

`segment.coordinates` is an array of:

```swift
CLLocationCoordinate2D
```

---

## ✅ 5. Get nearby street segments (optional)

To highlight all restricted streets near the user:

```swift
let segments = RestrictionService.shared.getStreetSegments(
    near: currentLocation,
    maxDistance: 150
)
```

---

# 🧠 Typical frontend flow

1. App starts → `load()`
2. User moves map → `getRestrictions(...)`
3. Draw restriction poles as pins
4. User taps a pin → `getStreetSegment(id:)`
5. Draw polyline for street segment

---

## 🏁 TL;DR — Only 3 essential calls

```swift
RestrictionService.shared.load()
RestrictionService.shared.getRestrictions(near:maxDistance:)
RestrictionService.shared.getNearestRestriction(to:)
```

The map UI doesn't decode JSON or touch files —  
it only uses this singleton like an **internal REST API without networking**.

---

### Optional helper feature ideas

- `isParkingAllowedNow()`
- `RestrictionType` parsing
- Icon mapping (`no parking`, `maximum time`, `street sweeping`)

If you want, I can generate documentation UI screenshots or a SwiftUI demo.

---

## Examples

### App launches → preload restriction data

```swift
RestrictionService.shared.load()
```

### 2. User moves on the map → get restrictions around map center
```swift
let results = RestrictionService.shared.getRestrictions(
    near: CLLocationCoordinate2D(latitude: lat, longitude: lon),
    maxDistance: 200
)
```

### 3. User taps a pin → get nearest restriction
```swift
let restriction = RestrictionService.shared.getNearestRestriction(
    to: coordinate
)
```

### 4. User zooms in → get smaller search radius
```swift
RestrictionService.shared.getRestrictions(
    near: map.centerCoordinate,
    maxDistance: 50
)
```

### 5. User zooms out → get bigger radius
```swift
RestrictionService.shared.getRestrictions(
    near: map.centerCoordinate,
    maxDistance: 1000
)
```

### 6. Map needs to highlight street segment for selected restriction
```swift
let segment = RestrictionService.shared.getStreetSegment(
    id: restriction.streetSegmentId
)
```

### 7. User wants “Can I park here?” the moment they stop driving
```swift
let nearest = RestrictionService.shared.getNearestRestriction(to: userCoord)
let allowed = nearest?.isParkingAllowedNow()
```
(We can implement isParkingAllowedNow() later — easy.)


### 8. User is walking/driving → continuously refresh
```swift
Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
    let restrictions = RestrictionService.shared.getRestrictions(
       near: currentLocation,
       maxDistance: 150
    )
}
```

### 9. Developer debug mode → print how many restrictions exist
```swift
print(RestrictionService.shared.restrictions.count)
```

### 10. UI wants to draw polyline of street segment
```swift
let polylinePoints = segment.coordinates // [CLLocationCoordinate2D]
```