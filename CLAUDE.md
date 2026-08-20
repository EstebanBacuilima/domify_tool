# DomifyTool

App móvil (Android + iOS) para el taller automotriz, contra la API de
`tool_core_backend`. Se construye desde cero con los formatos y estándares de las
skills de Flutter; no hay código anterior que arrastrar.

Las reglas de arquitectura y de método son globales: viven en las skills
`flutter-project-setup`, `flutter-feature-slice` y `flutter-silent-bugs`, y en
`~/.claude/CLAUDE.md`. Aquí solo va lo que es específico de este proyecto.

## Lo que cambia respecto al estándar

La fuente de verdad es una API, no almacenamiento local. Eso activa cuatro
cosas que las skills marcan como "solo cuando haga falta":

| | Por qué aquí sí |
|---|---|
| `data/models/` + mapper | El JSON tiene otra forma que la entidad. Un `Map<String, dynamic>` que llegue a `presentation` es un fallo de capa |
| `Failure` por caso | Sin conexión, 401, 404, 500 y timeout pintan cosas distintas |
| Estados de carga visibles | Con red el spinner se ve de verdad; `isSaving` deja de ser decorativo |
| Ids del servidor | No se genera `uuid` en cliente |

`hive_ce` **no está instalado**. Entrará cuando haga falta caché u offline, y
entonces su papel es caché, no almacén.

## Orden de la capa de datos, en cada feature

```
contrato → implementación FALSA en memoria → UI completa → cliente HTTP real
```

La UI avanza sin depender del backend, y el falso se queda como doble de test.

## Tests

No se busca cobertura. Se cubren **los caminos de error**, que son los que no se
pueden provocar a mano: timeout, 401, sin conexión. Y el error que se pisa con
el siguiente `emit`.

## Estado

Fase 0 cerrada (20 de agosto de 2026): proyecto creado
(`com.domifytech.domify_tool`), estructura de carpetas, dependencias
—`flutter_bloc`, `equatable`, `go_router`, `dio`, `flutter_secure_storage`—,
`bootstrap.dart` con `AppBlocObserver`. Sin features todavía. Repositorio git
inicializado, sin commits ni remoto.

**Siguiente: fase 1, autenticación.** Falta del backend el endpoint de login
(ruta, cuerpo, respuesta), cómo viaja el token, si hay refresh, y la base URL de
desarrollo.
