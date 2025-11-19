# App

### get maps

```mermaid
sequenceDiagram
User->>UI: Opens map
UI->>Controller: POST /parking-restrictions (lat, lng, radius)
Controller->>UseCase: execute(request)

UseCase->>PRRepo: getParkingRestrictions()
PRRepo-->>UseCase: ParkingRestrictionRaw[]

loop for each restriction
    UseCase->>PREntity: createEntity(raw)
    PREntity-->>UseCase: entity

    UseCase->>PREntity: isWithinRadius(userLat, userLng, radius)
    PREntity-->>UseCase: bool

    UseCase->>Presenter: present(entity)
    Presenter-->>UseCase: PRResponseModel
end

UseCase-->>Controller: List<PRResponseModel>
Controller-->>UI: 200 OK
UI-->>User: Show markers

```


```mermaid

classDiagram

namespace domain {
  class ParkingRestrictionEntity {
    +string id
    +string streetName
    +double longitude
    +double latitude
    +Date startTime
    +Date endTime
    +bool[] weekDays
    +string description
    +int hourlyRate

    +isWithinRadius(lat, lng, radius) bool
    +isActiveNow(Date now) bool
  }
}

namespace persistence {
  class ParkingRestrictionRaw {
    +string id
    +string streetName
    +double longitude
    +double latitude
    +string description
    +int hourlyRate
    +Date startTime
    +Date endTime
    +bool[] weekDays
  }

  class ParkingRestrictionRepository {
    +getParkingRestrictions() ParkingRestrictionRaw[]
  }
}

namespace DTO {
  class ParkingRestrictionDTO {
      +string streetName
      +double longitude
      +double latitude
      +string description
      +int hourlyRate
      +Date start
      +Date end
      +boolean[] weekDays
  }
}

```

<!-- class PlacesPersistence {
      +string streetId
      +double longitude
      +double latitude
      +string nameStreet
      +int hourlyRate
    }

    class ReglementationPeriodsPersistence {
      +string code
      +number periodId
      +string description
    }

    class PeriodsPersistence {
      +int id
      +date startTime
      +date endTime
      +boolean monday
      +boolean tuesday
      +boolean wednesday
      +boolean saturday
      +boolean sunday
    }

    class EmplacementReglamentationsPersistence {
      +string emplacementId
      +string codeAutocollant
    } -->