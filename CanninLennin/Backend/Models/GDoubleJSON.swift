import CoreLocation
import Foundation

struct StreetSegmentGeoJSON: Decodable {
  let features: [StreetSegmentFeature]
}

struct StreetSegmentFeature: Decodable {
  let geometry: StreetSegmentGeometry
  let properties: StreetSegmentProperties
}

struct StreetSegmentGeometry: Decodable {
  let coordinates: [[Double]]
}

struct StreetSegmentProperties: Decodable {
  let COTE_RUE_ID: Int
  let NOM_VOIE: String
  let DEBUT_ADRESSE: Int
  let FIN_ADRESSE: Int
}

extension StreetSegmentFeature {
  func toStreetSegment() -> StreetSegment {
    let coords = geometry.coordinates.map { pair in
      CLLocationCoordinate2D(latitude: pair[1], longitude: pair[0])
    }
    return StreetSegment(
      id: properties.COTE_RUE_ID, coordinates: coords, streetName: properties.NOM_VOIE,
      addressStart: properties.DEBUT_ADRESSE, addressEnd: properties.FIN_ADRESSE)

  }
}