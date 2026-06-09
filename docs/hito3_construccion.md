# Hito 3 - Construccion Aloja

## Version Iterativa Implementada

La version del hito 3 extiende el avance del hito 2 con un flujo funcional de
busqueda, registro, gestion de publicaciones, pago simulado y feedback.

### Funcionalidades

- Registro y acceso a perfil desde `RegisterPage` y `ProfilePage`.
- Busqueda de alojamientos por destino, precio maximo y cantidad de huespedes.
- Gestion de publicaciones para usuarios registrados:
  - crear publicacion;
  - editar publicacion;
  - pausar o activar publicacion;
  - eliminar publicacion.
- Reserva con pago simulado usando metodo de pago y numero de noches.
- Feedback posterior a la reserva con comentario y calificacion de 1 a 5.
- Recalculo automatico de rating promedio despues de cada comentario.

## Codigo Fuente

El codigo mantiene la separacion por capas definida en el hito 2:

- `lib/main.dart`: experiencia principal, busqueda, publicaciones, pago y
  feedback.
- `lib/domain/models/listing.dart`: modelo de dominio de alojamientos,
  comentarios, estado y reglas de busqueda.
- `lib/data/repositories/auth_repository.dart`: contrato y repositorio de
  autenticacion.
- `lib/registrase.dart` y `lib/perfil.dart`: registro, inicio de sesion,
  actualizacion de perfil y cierre de sesion.

## Plan De Pruebas

| Caso | Objetivo | Resultado esperado |
| --- | --- | --- |
| Registro de usuario | Validar que el usuario pueda crear cuenta | Home muestra sesion activa |
| Busqueda por destino | Filtrar alojamientos por ciudad, region o titulo | Solo aparecen coincidencias activas |
| Busqueda por precio | Excluir alojamientos sobre presupuesto | Resultados con precio menor o igual |
| Busqueda por huespedes | Mostrar alojamientos con capacidad suficiente | Resultados con cupo mayor o igual |
| Crear publicacion | Registrar una oferta propia | Aparece en resultados y panel de gestion |
| Pausar publicacion | Ocultar una oferta temporalmente | No aparece en busquedas publicas |
| Pago simulado | Confirmar reserva con metodo y noches | Se muestra confirmacion de pago |
| Feedback | Enviar comentario y estrellas | Se agrega comentario y se recalcula rating |

## Pruebas Automatizadas

- `test/widget_test.dart`: render inicial de la aplicacion.
- `test/auth_view_model_test.dart`: registro, login fallido y logout.
- `test/listing_model_test.dart`: filtros de busqueda, estado pausado y
  recalculo de rating.
