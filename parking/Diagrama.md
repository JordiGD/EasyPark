@startuml
title Microservicio de Parqueaderos

' =========================
' CONTROLLER
' =========================
package "Controller" {
  class ParkingController {
    + saveParking(parkingDTO)
    + updateParking(parkingDTO)
    + getParkingById(id)
    + getParkingByOwnerId(id)
    + getAllParkings()
    + getStatusParkingById(id)
  }
  class SpaceController {
    + createSpace(parkingId)
    + getSpacesByParking(parkingId)
    + updateStatusSpace(spaceId)
    + getSpaceStatusById(spaceId)
  }
}

' =========================
' SERVICE
' =========================
package "Service" {
  class ParkingService {
    + saveParking(parkingDTO)
    + updateParking(parkingDTO)
    + getParkingById(id)
    + getParkingByOwnerId(id)
    + getAllParkings()
    + getStatusParkingById(id)
  }
  class SpaceService {
    + createSpace(parkingId)
    + getSpacesByParking(parkingId)
    + updateStatusSpace(spaceId)
    + getSpaceStatusById(spaceId)
  }
}

' =========================
' REPOSITORY
' =========================
package "Repository" {
  interface ParkingRepo
  interface SpaceRepo
}

' =========================
' ENTITY
' =========================
package "Entity" {
  class Parking {
    - parkingID: Long
    - ownerID: Long
    - name: String
    - address: String
    - pricePerHour: Double
    - availability: Boolean
    - latitude: Double
    - longitude: Double
  }

  class Space {
    - spaceID: Long
    - parkingID: Long
    - number: String
    - status: String
  }
}

' =========================
' DTO
' =========================
package "DTO" {
  class ParkingDTO {
    - parkingID: Long
    - ownerID: Long
    - name: String
    - address: String
    - pricePerHour: Double
    - availability: Boolean
    - latitude: Double
    - longitude: Double
  }

  class SpaceDTO {
    - spaceID: Long
    - parkingID: Long
    - number: String
    - status: String
  }
}

' =========================
' MAPPER
' =========================
package "Mapper" {
  interface ParkingMapper {
    + toDTO(parking)
    + toEntity(parkingDTO)
  }

  interface SpaceMapper {
    + toDTO(space)
    + toEntity(spaceDTO)
  }
}

' =========================
' RELACIONES
' =========================

' Controller -> Service
ParkingController --> ParkingService
SpaceController --> SpaceService

' Service -> Repo
ParkingService --> ParkingRepo
SpaceService --> SpaceRepo

' Service -> Mapper
ParkingService --> ParkingMapper
SpaceService --> SpaceMapper

' Mapper -> Entity / DTO
ParkingMapper --> Parking
ParkingMapper --> ParkingDTO

SpaceMapper --> Space
SpaceMapper --> SpaceDTO

' Relaciones internas
Parking "1" --> "0..*" Space

@enduml