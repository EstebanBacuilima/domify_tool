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

## Entorno

El backend de desarrollo escucha en `http://localhost:5125/api/v1/`. El
mecanismo (`--dart-define-from-file`, `Env`, cleartext en Android) está en la
skill `flutter-project-setup`; aquí solo va el valor y lo que es de esta
máquina.

`config/dev.json` no se versiona porque el host cambia según dónde corra la
app: `localhost` en el simulador de iOS, `10.0.2.2` en el emulador de Android,
la IP de la LAN en un móvil físico —y entonces Kestrel tiene que escuchar en
`0.0.0.0`—. La plantilla versionada es `config/dev.example.json`.

En Android compilamos contra **API 37.0** (Android 17), no contra el 36 que
propone Flutter: `flutter_secure_storage 11` exige 37 y el SDK ya solo publica
plataformas con minor. `compileSdkMinor` está fijado en `android/app` y, para
los plugins, en el `subprojects` de `android/build.gradle.kts`. `targetSdk` se
queda donde lo pone Flutter.

## Estado

Fase 0 cerrada (20 de agosto de 2026): proyecto creado
(`com.domifytech.domify_tool`), estructura de carpetas, dependencias
—`flutter_bloc`, `equatable`, `go_router`, `dio`, `flutter_secure_storage`—,
`bootstrap.dart` con `AppBlocObserver`. Configuración de entorno cerrada:
`Env` validado en `bootstrap` antes del primer frame. Sin features todavía.
Repositorio git inicializado, sin commits ni remoto.

**Siguiente: fase 1, autenticación.** Falta del backend el endpoint de login
(ruta, cuerpo, respuesta), cómo viaja el token y si hay refresh.
