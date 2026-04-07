@startuml
title Apps vs Microservicio de Usuarios

actor Conductor
actor Propietario
actor Administrador

' =========================
' APP CONDUCTORES
' =========================
rectangle "App Conductores" {
  Conductor --> (Registrar Usuario)
  Conductor --> (Login)
  Conductor --> (Actualizar Usuario)
  Conductor --> (Registrar Vehiculo)
  Conductor --> (Actualizar Vehiculo)
}

' =========================
' APP PROPIETARIOS
' =========================
rectangle "App Propietarios" {
  Propietario --> (Registrar Propietario)
  Propietario --> (LoginPropietarios)
  Propietario --> (Actualizar Propietario)
  Propietario --> (Registrar Parqueadero)
  Propietario --> (Actualizar Parqueadero)
}

' =========================
' APP ADMIN
' =========================
rectangle "App Administrador" {
  Administrador --> (Login Admin)
  Administrador --> (Gestionar Usuarios)
}

' =========================
' MICROSERVICIO
' =========================
rectangle "Microservicio de Usuarios" {

  rectangle "UserController" {
    (saveUser)
    (updateUser)
    (login)
  }

  rectangle "DriverController" {
    (saveVehicule)
    (updateVehicule)
  }

  rectangle "OwnerController" {
    (saveParking)
    (updateParking)
  }
}

' =========================
' CONEXIONES
' =========================

' Conductores
(Registrar Usuario) --> (saveUser)
(Login) --> (login)
(Actualizar Usuario) --> (updateUser)
(Actualizar Vehiculo) --> (updateVehicule)
(Registrar Vehiculo) --> (saveVehicule)

' Propietarios
(Registrar Propietario) --> (saveUser)
(LoginPropietarios) --> (login)
(Actualizar Propietario) --> (updateUser)
(Actualizar Parqueadero) --> (updateParking)
(Registrar Parqueadero) --> (saveParking)

' Admin
(Login Admin) --> (login)
(Gestionar Usuarios) --> (updateUser)

@enduml