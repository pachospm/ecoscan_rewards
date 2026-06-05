# 🌱 EcoScan Rewards — Guía didáctica: ¿Cómo se construyó la app?

> **Para mis estudiantes.** Este documento explica, paso a paso y en orden, cómo se
> terminó de construir la aplicación **EcoScan Rewards**. La idea no es solo que vean
> el código final, sino que **entiendan las decisiones**: por qué se organizó así, qué
> hace cada pieza y cómo se conectan entre sí.
>
> Léanlo con el proyecto abierto al lado e id abriendo los archivos que se mencionan.

---

## 1. ¿Qué es EcoScan Rewards?

Es una app de reciclaje. El usuario toma una foto de un residuo, la app usa
**Machine Learning (ML Kit de Google)** para reconocer de qué material es
(plástico, vidrio, metal, cartón, papel…), y le otorga **puntos de recompensa**.
Hay dos tipos de usuario:

- **Reciclador (`recycler`)**: escanea residuos, gana puntos, ve su historial y su nivel.
- **Administrador (`admin`)**: ve estadísticas globales, usuarios, registros y revisa
  detecciones de baja confianza.

Toda la información se guarda **localmente** en el teléfono con una base de datos
**SQLite**. No hay servidor: es una app autocontenida, ideal para aprender.

---

## 2. El punto de partida (lo que ya estaba hecho)

Cuando retomé el proyecto, en clase ya habíamos construido los **cimientos**:

```
lib/
├── core/                      ✅ YA EXISTÍA
│   ├── constants/app_constants.dart
│   ├── theme/app_theme.dart
│   ├── utils/ (date_util, hash_util)
│   ├── animations/ (fade_slide, scale_tap)
│   └── routes/app_routes.dart   (sin terminar de conectar)
├── data/
│   └── models/                ✅ YA EXISTÍA (user, recycling_record, reward_point, detection_log)
└── main.dart                  (incompleto: usaba clases que aún no existían)
```

Es decir: teníamos los **datos** (modelos) y la **apariencia** (tema, constantes),
pero **faltaba toda la lógica y las pantallas**. El `main.dart` y las rutas ya
*nombraban* pantallas y "viewmodels" que todavía no habíamos creado — por eso daba error.

> 🧠 **Lección 1:** Es normal construir una app "de afuera hacia adentro" o "de abajo
> hacia arriba". Aquí empezamos por la base (modelos y estilos) y luego subimos hacia
> la lógica y la interfaz. Lo importante es tener claro **el plano completo** antes de
> seguir.

---

## 3. La arquitectura: ¿por qué tantas carpetas?

La app usa una arquitectura en **capas** inspirada en *Clean Architecture* y el
patrón **MVVM** (Model–View–ViewModel). La regla de oro es:

> **Cada capa solo conoce a la que tiene justo debajo. Nunca al revés.**

```
┌─────────────────────────────────────────────────────────┐
│  PRESENTATION  (lo que el usuario ve y toca)              │
│  ├── views/      → Pantallas (Widgets)                   │
│  ├── widgets/    → Piezas reutilizables de UI            │
│  └── viewmodels/ → El "cerebro" de cada pantalla         │
└───────────────────────────┬─────────────────────────────┘
                            │ (la vista le pide cosas al viewmodel)
┌───────────────────────────▼─────────────────────────────┐
│  DATA  (de dónde salen y a dónde van los datos)          │
│  ├── repositories/ → Hablan con la base de datos         │
│  ├── services/     → Lógica especializada (ML, puntos…)  │
│  ├── models/       → La forma de los datos               │
│  └── datasource/   → La base de datos SQLite en sí       │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  CORE  (cosas transversales que usa toda la app)         │
│  constantes · tema · utilidades · rutas · animaciones    │
└─────────────────────────────────────────────────────────┘
```

**¿Por qué separar así?** Porque cada parte se puede entender, probar y cambiar por
separado. Si mañana cambiamos SQLite por un servidor en internet, **solo tocaríamos
los repositorios**; las pantallas ni se enterarían. Eso es *bajo acoplamiento*.

---

## 4. Recorrido por capas (en orden de construcción)

### 4.1 CORE — los cimientos

| Archivo | Para qué sirve |
|---|---|
| `core/constants/app_constants.dart` | Valores fijos de toda la app: roles (`rolAdmin`, `rolRecycler`), materiales, puntos por material, umbrales de confianza del ML, nombre de la base de datos. |
| `core/theme/app_theme.dart` | El "diseño" centralizado: colores, tipografía (Google Fonts), estilos de botones, tarjetas, inputs… Todo el look oscuro/ecológico vive aquí. |
| `core/utils/hash_util.dart` | Convierte contraseñas a **SHA-256**. Nunca guardamos contraseñas en texto plano. |
| `core/utils/date_util.dart` | Formatea fechas ("hace 3 min", "15 abr 2026"). |
| `core/animations/` | Animaciones reutilizables (aparecer con desvanecido, "rebote" al tocar). |
| `core/routes/app_routes.dart` | El "mapa" de navegación: cada pantalla tiene un nombre de ruta. |

> 🧠 **Lección 2 — Centralizar constantes.** Fíjense que el nombre de la base de datos,
> los puntos por material o los roles **no están escritos a mano por todos lados**, sino
> en un único lugar (`AppConstants`). Si hay que cambiar algo, se cambia una sola vez.

```dart
// app_constants.dart — un solo lugar para la "verdad"
static const Map<String, int> pointsPerMaterial = {
  materialPlastic: 10,
  materialGlass: 15,
  materialMetal: 20,
  materialCardboard: 8,
  materialPaper: 5,
  materialUnknown: 2,
};
```

---

### 4.2 DATA — Modelos: la forma de los datos

Un **modelo** es una clase Dart que representa una fila de la base de datos.
Por ejemplo `UserModel` representa un usuario. Cada modelo tiene 3 cosas importantes:

```dart
class UserModel {
  final int? id;
  final String name;
  // ...

  // 1) fromMap: convierte un registro de SQLite (un Map) → objeto Dart
  factory UserModel.fromMap(Map<String, dynamic> map) { ... }

  // 2) toMap: convierte el objeto Dart → Map para guardarlo en SQLite
  Map<String, dynamic> toMap() { ... }

  // 3) copyWith: crea una copia cambiando solo algunos campos
  UserModel copyWith({ ... }) { ... }
}
```

> 🧠 **Lección 3 — `fromMap`/`toMap` son "traductores".** SQLite habla en `Map`
> (columnas y valores); nuestro código habla en objetos. Estos métodos traducen entre
> los dos mundos. A esto se le llama *serialización*.

Modelos del proyecto: `UserModel`, `RecyclingRecordModel` (un reciclaje),
`RewardPointModel` (una transacción de puntos) y `DetectionLogModel` (el registro
crudo de lo que detectó el ML).

---

### 4.3 DATA — DataSource: la base de datos SQLite

Archivo: `data/datasource/local/database_helper.dart`

Es el **único** archivo que habla directamente con SQLite. Hace tres trabajos:

1. **Abrir/crear** la base de datos (patrón *Singleton*: una sola instancia en toda la app).
2. **Crear las tablas** la primera vez (`_createTables`).
3. **Insertar datos de prueba** (`_insertSeedData`) para que la app no arranque vacía.

```dart
// Singleton: siempre la misma instancia
static final DatabaseHelper instance = DatabaseHelper._internal();

// Getter "perezoso": la BD se crea solo la primera vez que se usa
Future<Database> get database async {
  _database ??= await _initDatabase();
  return _database!;
}
```

También ofrece métodos genéricos (`insert`, `query`, `update`, `delete`, `rawQuery`)
que los repositorios usarán. Las tablas son: `users`, `recycling_records`,
`reward_points` y `detection_logs`.

Los **datos semilla** crean 3 usuarios de prueba y varios reciclajes, para que al
abrir la app ya haya algo que mostrar:

| Usuario | Email | Contraseña | Rol |
|---|---|---|---|
| Administrador | `admin@ecoscan.com` | `admin123` | admin |
| María García | `maria@ecoscan.com` | `recycler123` | recycler |
| Carlos López | `carlos@ecoscan.com` | `recycler123` | recycler |

---

### 4.4 DATA — Services: lógica especializada

Los **servicios** contienen lógica que no es "guardar/leer", sino *procesar*.

| Servicio | Qué hace |
|---|---|
| `ml_kit_detection_service.dart` | Toma una foto y usa **ML Kit** (Image Labeling + Object Detection) para sacar etiquetas como `bottle`, `can`, `glass`. |
| `material_mapping_service.dart` | Traduce esas etiquetas en inglés a un **material reciclable** ("bottle"→plástico, "can"→metal). Incluye reglas combinadas (bottle+glass = vidrio). |
| `reward_calculation_service.dart` | Calcula **cuántos puntos** dar (con bonus por alta confianza) y el **nivel** del usuario (Bronce, Plata, Oro, Platino). |
| `session_service.dart` | Recuerda quién inició sesión usando `SharedPreferences` (para no pedir login cada vez). |

```dart
// reward_calculation_service.dart — la "regla de negocio" de los puntos
int calculatePoints(String material, double confidence) {
  if (material == AppConstants.materialUnknown) return 0;
  final basePoints = AppConstants.pointsPerMaterial[material] ?? 0;
  if (confidence >= AppConstants.highConfidenceThreshold) {
    return (basePoints * 1.2).round(); // 20% extra si el ML está muy seguro
  }
  return basePoints;
}
```

> 🧠 **Lección 4 — Separar la lógica de negocio.** ¿Por qué los puntos se calculan en un
> servicio y no dentro de la pantalla? Porque así esa regla se puede **reutilizar y probar**
> sin abrir la app. La pantalla solo *pide* el resultado, no sabe *cómo* se calcula.

---

### 4.5 DATA — Repositories: la puerta a los datos

Un **repositorio** es el intermediario entre los viewmodels y la base de datos.
Su trabajo: ofrecer métodos con nombres claros ("dame los reciclajes de este usuario")
y por dentro armar la consulta SQL.

```dart
// recycling_repository.dart
Future<List<RecyclingRecordModel>> getRecordsByUser(int userId) async {
  final results = await _db.query(
    'recycling_records',
    where: 'user_id = ?',
    whereArgs: [userId],
    orderBy: 'created_at DESC',
  );
  return results.map((m) => RecyclingRecordModel.fromMap(m)).toList();
}
```

Repositorios del proyecto: `AuthRepository` (login), `UserRepository`,
`RecyclingRepository`, `RewardRepository`, `DetectionRepository`.

> 🧠 **Lección 5 — El patrón Repositorio.** Los viewmodels **nunca** escriben SQL.
> Le piden todo al repositorio. Así, si cambiamos cómo se guardan los datos, los
> viewmodels no cambian. Es como pedir un café: no te metes a la cocina, le pides al
> mesero (el repositorio).

---

### 4.6 PRESENTATION — ViewModels: el cerebro de cada pantalla

Aquí está el corazón del patrón **MVVM**. Un *ViewModel*:

- **Guarda el estado** de la pantalla (cargando, datos, error…).
- **Tiene la lógica** de qué hacer cuando el usuario actúa.
- **Avisa a la vista** cuando algo cambia, con `notifyListeners()`.

Todos extienden `ChangeNotifier` y siguen el mismo molde. Ejemplo, el login:

```dart
class AuthViewModel extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;   // estado interno (privado)
  AuthStatus get status => _status;       // la vista solo puede leer

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();                     // 🔔 "¡pantalla, vuelve a dibujarte!"

    final user = await _authRepository.login(email, password);
    if (user == null) {
      _errorMessage = 'Credenciales incorrectas';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
    // ...guarda sesión, marca éxito...
    _status = AuthStatus.success;
    notifyListeners();
    return true;
  }
}
```

> 🧠 **Lección 6 — El estado vive en el ViewModel, no en el Widget.** La pantalla es
> "tonta": solo dibuja lo que el viewmodel le dice. Cuando el estado cambia,
> `notifyListeners()` hace que la pantalla se redibuje sola. Esto se llama
> **programación reactiva**.

Patrones que se repiten en TODOS los viewmodels (búsquenlos):

1. **Inyección de dependencias** por el constructor (reciben repos/servicios, o usan los por defecto). Esto permite *testear* con datos falsos.
2. Un **enum de estado** (`idle`, `loading`, `success`, `error`).
3. Campos privados (`_`) + *getters* públicos de solo lectura.
4. Métodos `async` que cambian el estado y llaman `notifyListeners()`.

ViewModels del proyecto: `AuthViewModel`, `ScanViewModel`, `RecyclerDashboardViewModel`,
`RewardViewModel`, `AdminDashboardViewModel`, `RecordsViewModel`.

---

### 4.7 PRESENTATION — Views y Widgets: la interfaz

- **Views** (`presentation/views/`) = las **pantallas** completas, organizadas por rol:
  `auth/` (splash, login), `recycler/` (home, scan, resultado, historial, recompensas,
  perfil) y `admin/` (home, usuarios, registros, revisión, estadísticas).
- **Widgets** (`presentation/widgets/`) = **piezas reutilizables**: `EcoCard`,
  `StatCard`, `MaterialBadge`, `ConfidenceIndicator`, `EmptyState`, `LoadingOverlay`,
  `RecyclingRecordTile`.

Las vistas usan el paquete **Provider** para escuchar a su viewmodel:

```dart
// Dentro de una pantalla:
final authVM = context.watch<AuthViewModel>();  // se redibuja si cambia
if (authVM.isLoading) return CircularProgressIndicator();
// context.read<...>()  → para LLAMAR un método sin escuchar cambios
```

> 🧠 **Lección 7 — `watch` vs `read`.** `watch` = "quiero enterarme cuando cambie"
> (para mostrar datos). `read` = "solo quiero llamar un método" (para botones). Usar el
> correcto evita redibujados innecesarios.

---

## 5. El flujo completo, de principio a fin (ejemplo: escanear)

Sigamos un escaneo para ver **cómo cooperan todas las capas**:

```
1. [VIEW] scan_screen → el usuario toma una foto
              │  context.read<ScanViewModel>().analyzeImage(foto, userId)
              ▼
2. [VIEWMODEL] ScanViewModel.analyzeImage()
              │  status = detecting; notifyListeners()
              ▼
3. [SERVICE] MlKitDetectionService → ML Kit analiza la imagen → etiquetas
              ▼
4. [SERVICE] MaterialMappingService → etiquetas → "plástico" + confianza
              ▼
5. [REPOSITORY] DetectionRepository.insertLog() → guarda el log en SQLite
              │  status = result; notifyListeners()
              ▼
6. [VIEW] detection_result_screen → muestra el material detectado
              │  el usuario confirma (o corrige) y pulsa "Guardar"
              ▼
7. [VIEWMODEL] ScanViewModel.confirmAndSave()
              │  RewardCalculationService.calculatePoints()  → cuántos puntos
              │  RecyclingRepository.insertRecord()          → guarda el reciclaje
              │  RewardRepository.insertPoints()             → guarda los puntos
              ▼
8. [VIEW] muestra "¡Ganaste X puntos!" 🎉
```

Fíjense cómo **cada capa solo habla con la siguiente**: la vista no sabe nada de SQL,
el viewmodel no sabe cómo funciona ML Kit por dentro, el repositorio no sabe que existe
una pantalla. Eso es una arquitectura limpia.

---

## 6. Cómo se ensambla todo: `main.dart`

El `main.dart` es el punto de arranque. Hace 3 cosas:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null); // fechas en español
  runApp(const EcoScanApp());
}
```

Y registra **todos los viewmodels** con `MultiProvider`, para que cualquier
pantalla pueda pedirlos:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel()),
    ChangeNotifierProvider(create: (_) => ScanViewModel()),
    // ...los demás...
  ],
  child: MaterialApp(
    theme: AppTheme.darkTheme,
    initialRoute: AppRoutes.splash,        // arranca en el splash
    onGenerateRoute: AppRoutes.onGenerateRoute, // navegación con animación
  ),
)
```

> 🧠 **Lección 8 — Inyección de dependencias global.** `MultiProvider` "deja disponibles"
> los viewmodels en lo alto del árbol de widgets. Cualquier pantalla hija los obtiene con
> `context.watch/read`, sin tener que pasarlos a mano de pantalla en pantalla.

---

## 7. Errores reales que corregimos (¡las mejores lecciones!)

Al terminar la app me encontré con bugs que **impedían que arrancara**. Los comparto
porque aprender a detectarlos vale más que el código perfecto:

| Problema encontrado | Por qué fallaba | Cómo se arregló |
|---|---|---|
| `database_helper.dart` estaba dentro de `data/models/` | Los `import` apuntaban a `data/datasource/local/` → no compilaba | Se movió a la ruta correcta |
| `PGRAMA foreing_keys` y `PRIMERAY KEY` en el SQL | Errores de tipeo en SQL → la BD no se creaba (crash) | `PRAGMA foreign_keys`, `PRIMARY KEY` |
| Columnas con typo (`correted_material`, `point`, `cofindence`) | El nombre de la columna **no coincidía** con el `toMap()` del modelo → crash al guardar | Se alinearon nombres de columnas y modelos |
| Tabla `users` con columna `create_at` pero el modelo usaba `created_at` | Desajuste → crash al leer usuarios | Se unificó a `created_at` |
| `FOREIGN KEY ... REFERENCES user(id)` | La tabla se llama `users`, no `user` | Se corrigió la referencia |
| Tema con llaves sin tilde (`'plastico'`) | La búsqueda de color devolvía `null` (los materiales llevan tilde) | Llaves con tilde (`'plástico'`) |
| `withOpacity(1.1)` | La opacidad va de 0.0 a 1.0; 1.1 es inválido | Se corrigió a `0.1` |
| `AndroidManifest.xml` sin permisos de cámara | La app no podía abrir la cámara ni usar ML Kit | Se añadieron permisos `CAMERA`, almacenamiento e internet |

> 🧠 **Lección 9 — Los nombres importan muchísimo.** La mayoría de bugs fueron **nombres
> que no coincidían** entre la base de datos y los modelos. En programación, una letra de
> diferencia (`create_at` vs `created_at`) rompe todo. Cuando algo falle, **comparen los
> nombres** carácter por carácter.

> 🧠 **Lección 10 — La herramienta que avisa: `flutter analyze`.** Antes de ejecutar la
> app, este comando revisa todo el código y lista los errores. Lo usamos hasta dejarlo en
> **0 errores**. Acostúmbrense a correrlo seguido.

---

## 8. Cómo ejecutar la app

```bash
flutter pub get      # descarga las dependencias
flutter analyze      # revisa que no haya errores
flutter run          # ejecuta en el emulador o celular
```

Inicien sesión con cualquiera de los usuarios de prueba (tabla de la sección 4.3).

---

## 9. Glosario rápido

- **MVVM**: patrón que separa *Modelo* (datos), *Vista* (UI) y *ViewModel* (lógica + estado).
- **ChangeNotifier / Provider**: la forma de Flutter de avisar a la UI que el estado cambió.
- **Repositorio**: clase que aísla el acceso a los datos (la "puerta" a la BD).
- **Servicio**: clase con lógica especializada (ML, cálculos) reutilizable.
- **Singleton**: una clase de la que solo existe **una** instancia en toda la app.
- **Inyección de dependencias**: pasarle a una clase lo que necesita (en vez de que se lo cree ella), para poder cambiarlo/probarlo.
- **Serialización (`toMap`/`fromMap`)**: convertir objetos ↔ formato de almacenamiento.
- **SQLite / SharedPreferences**: BD local para datos estructurados / almacenamiento simple clave-valor.

---

## 10. Ejercicios propuestos 🎯

Para afianzar lo aprendido, intenten (de menor a mayor dificultad):

1. **Fácil:** Cambien los puntos de un material en `AppConstants` y observen cómo se
   refleja en toda la app sin tocar nada más. *(Demuestra el valor de centralizar.)*
2. **Fácil:** Agreguen un color nuevo a un material en `AppTheme.materialColors`.
3. **Medio:** Añadan un material nuevo (p. ej. "orgánico"): constante, puntos, color y
   reglas de mapeo en `MaterialMappingService`.
4. **Medio:** Creen un widget nuevo en `widgets/` y úsenlo en una pantalla.
5. **Difícil:** Agreguen una pantalla de "Top recicladores" usando
   `RewardRepository.getLeaderboard()` (¡el método ya existe!).
6. **Reto:** Escriban un *test unitario* para `RewardCalculationService.calculatePoints()`.
   Verán por qué la lógica de negocio está separada: se puede probar sin la UI.

---

### Cierre

La app no es magia: es **capas pequeñas y ordenadas que cooperan**. Si entienden el
camino *Vista → ViewModel → Repositorio/Servicio → Base de datos* y la regla de que
"cada capa solo conoce a la de abajo", pueden construir cualquier app con esta misma
estructura.

¡A reciclar (código)! 🌍♻️
