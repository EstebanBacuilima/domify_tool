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
contrato → sources + implementación real → UI completa
```

El backend existe y corre en local, así que se prueba contra la API desde el
primer día: un endpoint que responde enseña más que cualquier simulación.

**El doble en memoria es opcional**, no un paso. Merece la pena en dos casos:
cuando el endpoint todavía no existe, y cuando hay que provocar un camino que
la API real no da a mano —sin conexión, timeout—. Si se escribe, se queda como
doble de test; si no, no se echa de menos.

`data/sources/` es lo único que toca HTTP y conoce rutas y nombres de campo.
El repositorio compone la fuente con lo demás y mapea DTO a entidad.

El desenvoltorio del sobre de la API es genérico y vive en
`core/network/api_client.dart`: ninguna feature vuelve a escribirlo.

## Tests

**No se escriben tests nuevos.** La verificación es en emulador o dispositivo,
contra la API real. Nada de widget tests.

Los que ya existen se mantienen porque cubren lo que a mano no se puede
provocar: el refresh single-flight del interceptor y las promesas del contrato.
Si uno estorba, se borra sin discutirlo.

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

## La API

Todo endpoint responde el mismo sobre, en camelCase:
`{"status":200,"message":"successful","data":{...}}`. Los errores lo reusan con
`data: null` y un **slug** en `message` (`invalid-credentials`), que es un
código, no texto para el usuario. `core/error/failure_messages.dart` traduce
los slugs conocidos y cae a un texto genérico con los demás.

Dos cosas que no se adivinan y cuestan una tarde:

- **Credenciales incorrectas son un `400`, no un `401`.** El 401 significa
  token muerto. Confundirlos hace que un login fallido dispare el flujo de
  sesión expirada.
- `validation-error` sí trae `data`, con forma de diccionario campo → slugs, y
  **las claves en PascalCase** (`{"Username":["username-required"]}`), porque
  son nombres de propiedad de FluentValidation.

Access token: 460 min. Refresh: 30 días y **rota en cada uso**. Reenviar un
refresh ya rotado hace que el backend revoque *todas* las sesiones del usuario,
así que el refresh del cliente tiene que ser single-flight.

## Estado

Fase 0 cerrada (20 de agosto de 2026): proyecto, estructura, dependencias,
`bootstrap.dart` con `AppBlocObserver`, y configuración de entorno con `Env`
validado antes del primer frame.

**Fase 1, autenticación — en curso.** Cerrado: entidad `UserProfile`, DTOs,
contrato `AuthRepository`, `TokenStore` con implementación segura y otra en
memoria, `AuthRemoteSource`, `HttpAuthRepository` y el mapeo de `Failure`.
Probado contra la API real: login, `/me`, credenciales incorrectas, validación,
logout y sesión caducada.

`AuthInterceptor` cerrado: adjunta el token, renueva una vez ante un 401 con
slug `unauthorized`, y el refresh es single-flight. Comprobado contra la API
real que una sesión con el access token muerto se renueva sola y que el refresh
rota; y con tests, que tres 401 simultáneos provocan una sola renovación.

**Siguiente:** estado, cubit y UI de login, más el cableado en `main.dart`
(`RepositoryProvider<AuthRepository>`, con el tipo del contrato explícito).
Register no tendrá pantalla.
