@startuml
title Microservicio de Usuarios - Arquitectura Completa

' =========================
' CONTROLLERS
' =========================
package "Controller" {
  class UserController {
    + saveUser(userDTO)
    + updateUser(userDTO)
    + login(userDTO)
  }

  class DriverController {
    + saveVehicule(driverDTO)
    + updateVehicule(driverDTO)
  }

  class OwnerController {
    + getOwnerById(idOwner)
  }
}

' =========================
' SERVICES
' =========================
package "Service" {
  class UserService {
    + saveUser(userDTO)
    + updateUser(userDTO)
    + login(email, password)
  }

  class DriverService {
    + saveVehicule(driverDTO)
    + updateVehicule(driverDTO)
  }

  class OwnerService {
    + getOwnerById(idOwner)
  }
}

' =========================
' REPOSITORIES
' =========================
package "Repository" {
  interface UserRepo {
    + findByEmail(email)
    + existsByEmail(email)
  }

  interface DriverRepo
  interface OwnerRepo
}

' =========================
' ENTITIES
' =========================
package "Entity" {
  class User {
    - userID: Long
    - name: String
    - phoneNumber: String
    - email: String
    - password: String
    - role: String
    - createdAt: LocalDateTime
  }

  class Driver {
    - driverID: Long
    - userID: Long
    - vehicule: String
    - plate: String
  }

  class Owner {
    - ownerID: Long
    - userID: Long
  }
}

' =========================
' DTOs
' =========================
package "DTO" {
  class UserDTO {
    - userID: Long
    - name: String
    - phoneNumber: String
    - email: String
    - password: String
    - role: String
    - createdAt: LocalDateTime
  }

  class DriverDTO {
    - driverID: Long
    - userID: Long
    - vehicule: String
    - plate: String
  }

  class OwnerDTO {
    - ownerID: Long
    - userID: Long
  }
}

' =========================
' MAPPERS
' =========================
package "Mapper" {
  interface UserMapper {
    + toDTO(user)
    + toEntity(userDTO)
  }

  interface DriverMapper {
    + toDTO(driver)
    + toEntity(driverDTO)
  }

  interface OwnerMapper {
    + toDTO(owner)
    + toEntity(ownerDTO)
  }
}

' =========================
' RELACIONES
' =========================

' Controller -> Service
UserController --> UserService
DriverController --> DriverService
OwnerController --> OwnerService

' Service -> Repository
UserService --> UserRepo
DriverService --> DriverRepo
OwnerService --> OwnerRepo

' Service -> Mapper
UserService --> UserMapper
DriverService --> DriverMapper
OwnerService --> OwnerMapper

' Mapper -> Entity / DTO
UserMapper --> User
UserMapper --> UserDTO

DriverMapper --> Driver
DriverMapper --> DriverDTO

OwnerMapper --> Owner
OwnerMapper --> OwnerDTO

' Relaciones de negocio
User "1" --> "0..1" Driver
User "1" --> "0..1" Owner

@enduml