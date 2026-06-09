# Hito 2 - Arquitectura Aloja

## Patron Arquitectonico

La aplicacion usa una arquitectura por capas con MVVM en la capa de UI:

- UI: widgets Flutter y `AuthViewModel`.
- Data: repositorios (`AuthRepository`, `ProjectRepository`) y servicios Firebase.
- Domain: modelos limpios (`AppUser`, `AlojaProject`).

## Patrones De Diseno

- Repository: aisla Firebase Auth y Firestore detras de contratos probables.
- MVVM: mueve el estado de autenticacion desde los widgets hacia `AuthViewModel`.
- Dependency Injection: las pantallas reciben repositorios opcionales para usar Firebase en produccion y fakes en pruebas.

## Diagrama De Clases

```mermaid
classDiagram
  class AppUser {
    +String id
    +String name
    +String email
    +toProfileMap()
  }
  class AlojaProject {
    +String id
    +String ownerId
    +ProjectStatus status
    +toMap()
  }
  class AuthViewModel {
    +AppUser? currentUser
    +bool isLoading
    +String? errorMessage
    +register()
    +login()
    +logout()
  }
  class AuthRepository {
    <<interface>>
    +register()
    +login()
    +updateProfile()
    +logout()
  }
  class FirebaseAuthRepository
  class AuthService {
    <<interface>>
    +createUser()
    +signIn()
    +signOut()
  }
  class UserProfileService {
    <<interface>>
    +getUser()
    +createUser()
    +updateUser()
  }
  class ProjectRepository {
    <<interface>>
    +watchUserProjects()
    +createProject()
  }

  AuthViewModel --> AuthRepository
  FirebaseAuthRepository ..|> AuthRepository
  FirebaseAuthRepository --> AuthService
  FirebaseAuthRepository --> UserProfileService
  ProjectRepository --> AlojaProject
  AuthRepository --> AppUser
```

## Diagrama De Secuencia: Registro

```mermaid
sequenceDiagram
  actor Usuario
  participant RegisterPage
  participant AuthViewModel
  participant AuthRepository
  participant FirebaseAuth
  participant Firestore

  Usuario->>RegisterPage: completa formulario y pulsa Crear cuenta
  RegisterPage->>RegisterPage: valida campos
  RegisterPage->>AuthViewModel: register(datos)
  AuthViewModel->>AuthRepository: register(datos)
  AuthRepository->>FirebaseAuth: createUser(email, password)
  FirebaseAuth-->>AuthRepository: uid
  AuthRepository->>Firestore: users/{uid}.set(profile)
  Firestore-->>AuthRepository: ok
  AuthRepository-->>AuthViewModel: AppUser
  AuthViewModel-->>RegisterPage: usuario autenticado
  RegisterPage-->>Usuario: vuelve a Home con sesion activa
```

## Modulos Implementados

- `lib/domain/models`: modelos de usuario y proyecto.
- `lib/data/services`: adaptadores Firebase Auth/Firestore.
- `lib/data/repositories`: contratos de autenticacion y proyectos.
- `lib/ui/features/auth/view_models`: estado y comandos del flujo de autenticacion.
- `lib/registrase.dart`, `lib/perfil.dart`, `lib/main.dart`: integracion de UI existente con el modulo nuevo.
