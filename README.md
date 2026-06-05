# EcoScan Rewards

App móvil de reciclaje hecha en **Flutter** que reconoce materiales reciclables a
partir de una foto usando **Machine Learning (Google ML Kit)** y otorga **puntos de
recompensa** a los usuarios. Toda la información se almacena localmente en el
dispositivo con **SQLite**.

---

## Características

- **Detección por cámara** de materiales (plástico, vidrio, metal, cartón, papel) con ML Kit.
- **Sistema de recompensas**: puntos por material, bonus por alta confianza y niveles (Bronce a Platino).
- **Dos roles de usuario**:
  - **Reciclador**: escanea, gana puntos, ve su historial, recompensas y perfil.
  - **Administrador**: estadísticas globales, gestión de usuarios, registros y revisión de detecciones.
- **Persistencia local** con SQLite (sin necesidad de servidor).
- **Sesión persistente** con contraseñas protegidas (SHA-256).
- **Interfaz** con tema oscuro/ecológico, animaciones y Google Fonts.

---

## Tecnologías

| Categoría | Paquetes |
|---|---|
| Estado | `provider` (patrón MVVM) |
| Base de datos | `sqflite`, `path` |
| Cámara / ML | `camera`, `google_mlkit_image_labeling`, `google_mlkit_object_detection` |
| Utilidades | `crypto`, `intl`, `shared_preferences`, `image_picker`, `uuid` |
| UI | `google_fonts`, `cupertino_icons` |

---

## Arquitectura

El proyecto sigue una arquitectura en capas (inspirada en Clean Architecture + **MVVM**):

```
PRESENTATION  ->  views / widgets / viewmodels   (lo que ve el usuario + estado)
      |
DATA          ->  repositories / services / models / datasource (SQLite)
      |
CORE          ->  constants / theme / utils / routes / animations
```

**Regla principal:** cada capa solo conoce a la que tiene debajo. Las vistas no
acceden a la base de datos directamente; lo hacen a través de viewmodels y repositorios.

### Estructura de carpetas

```
lib/
├── core/
│   ├── constants/      # Constantes globales (roles, materiales, puntos)
│   ├── theme/          # Tema, colores y tipografía
│   ├── utils/          # Hash de contraseñas, formateo de fechas
│   ├── animations/     # Animaciones reutilizables
│   └── routes/         # Definición de rutas y navegación
├── data/
│   ├── datasource/     # DatabaseHelper (SQLite)
│   ├── models/         # Modelos de datos (toMap/fromMap)
│   ├── repositories/   # Acceso a datos (auth, user, recycling, reward, detection)
│   └── services/       # ML Kit, mapeo de materiales, cálculo de puntos, sesión
├── presentation/
│   ├── viewmodels/     # Lógica + estado (ChangeNotifier + Provider)
│   ├── views/          # Pantallas (auth / recycler / admin)
│   └── widgets/        # Componentes de UI reutilizables
└── main.dart           # Punto de entrada + MultiProvider
```

---

## Cómo ejecutar

Requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart >= 3.11) y un emulador o dispositivo físico.

```bash
# 1. Clonar el repositorio
git clone https://github.com/pachospm/ecoscan_rewards.git
cd ecoscan_rewards

# 2. Instalar dependencias
flutter pub get

# 3. (Opcional) Verificar que todo compila
flutter analyze

# 4. Ejecutar
flutter run
```

### Usuarios de prueba

La app crea datos semilla la primera vez que se abre:

| Rol | Email | Contraseña |
|---|---|---|
| Administrador | `admin@ecoscan.com` | `admin123` |
| Reciclador | `maria@ecoscan.com` | `recycler123` |
| Reciclador | `carlos@ecoscan.com` | `recycler123` |

---

## Ramas

- `main` — rama principal (versión estable).
- `develop` — integración de funcionalidades.
- `feature/core` — desarrollo del núcleo de la app.

---

## Licencia

Proyecto educativo. Uso libre con fines de aprendizaje.
