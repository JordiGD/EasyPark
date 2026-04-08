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
    + getAllParkings()
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
  }
}

' =========================
' REPOSITORY
' =========================
package "Repository" {
  interface ParkingRepo
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

' Service -> Repo
ParkingService --> ParkingRepo

' Service -> Mapper
ParkingService --> ParkingMapper

' Mapper -> Entity / DTO
ParkingMapper --> Parking
ParkingMapper --> ParkingDTO

SpaceMapper --> Space
SpaceMapper --> SpaceDTO

' Relaciones internas
Parking "1" --> "0..*" Space

@enduml