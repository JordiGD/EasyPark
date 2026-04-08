@startuml
title Apps vs Microservicio de Parqueaderos

actor Conductor
actor Propietario
actor Administrador

' =========================
' APP CONDUCTORES
' =========================
rectangle "App Conductores" {
  Conductor --> (Ver Parqueaderos)
  Conductor --> (Ver Detalle Parqueadero)
  Conductor --> (Ver Espacios)
  Conductor --> (Ver Estado Espacio)
  Conductor --> (Estado Parqueadero)
}

' =========================
' APP PROPIETARIOS
' =========================
rectangle "App Propietarios" {
  Propietario --> (Registrar Parqueadero)
  Propietario --> (Actualizar Parqueadero)
  Propietario --> (Ver Mis Parqueaderos)
  Propietario --> (Ver Estado Parqueadero)
  Propietario --> (Crear Espacios)
  Propietario --> (Gestionar Espacios)
}

' =========================
' APP ADMIN
' =========================
rectangle "App Administrador" {
  Administrador --> (Ver Todos los Parqueaderos)
  Administrador --> (Actualizar Parqueadero)
  Administrador --> (Ver Estado Parqueadero)
}

' =========================
' MICROSERVICIO
' =========================
rectangle "Microservicio de Parqueaderos" {

  rectangle "ParkingController" {
    (saveParking)
    (updateParking)
    (getParkingById)
    (getParkingByOwnerId)
    (getAllParkings)
    (getStatusParkingById)
  }

  rectangle "SpaceController" {
    (createSpace)
    (getSpacesByParking)
    (updateStatusSpace)
    (getSpaceStatusById)
  }
}

' =========================
' CONEXIONES
' =========================

' Conductores
(Ver Parqueaderos) --> (getAllParkings)
(Ver Detalle Parqueadero) --> (getParkingById)
(Ver Espacios) --> (getSpacesByParking)
(Ver Estado Espacio) --> (getSpaceStatusById)
(Estado Parqueadero) --> (getStatusParkingById)

' Propietarios
(Registrar Parqueadero) --> (saveParking)
(Actualizar Parqueadero) --> (updateParking)
(Ver Mis Parqueaderos) --> (getParkingByOwnerId)
(Ver Estado Parqueadero) --> (getStatusParkingById)
(Crear Espacios) --> (createSpace)
(Gestionar Espacios) --> (updateStatusSpace)

' Admin
(Ver Todos los Parqueaderos) --> (getAllParkings)

@enduml