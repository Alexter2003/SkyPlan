# Proyecto Final — Enunciado Original

> Fuente: `Enunciado Proyecto Final.pdf` (Universidad Mesoamericana — Programación
> Dispositivos Móviles, Ing. German Rodríguez). Convertido con `markitdown` y
> limpiado de artefactos de extracción. Este archivo es la referencia canónica
> de requerimientos; la skill `project-requirements` la usa para verificar
> cumplimiento.

## Descripción del Problema

Se requiere desarrollar una aplicación móvil que funcione como un
"Planificador de Actividades" donde se puedan registrar diferentes
ubicaciones físicas obtenidas por la ubicación del teléfono o de la API de
Google Maps, y se puedan guardar actividades a realizar en dichas
ubicaciones. Estas actividades deben estar condicionadas según el clima de
la ubicación y fecha guardadas, para que la aplicación recomiende
realizarla o posponerla. La aplicación debe desarrollarse con el framework
de desarrollo móvil **Flutter**.

## Requisitos del Proyecto

### 1. Login — 10%
- a. Pantalla de login que maneje las credenciales de forma **cifrada**,
  validándolas por medio de una API a la base de datos de la aplicación.
- b. Pantalla principal con menú lateral con opciones para acceder a los
  módulos de la aplicación y un botón para cerrar sesión.
- c. Desarrollo de logotipo de la aplicación y paleta de colores.

### 2. Módulo de Usuario — 10%
- a. Visualización de la información del usuario logueado, con opción de
  editar datos personales **excepto** nombre de usuario y contraseña.
- b. Recuperación de contraseña con correo registrado: se asigna una
  contraseña temporal que debe cambiarse al loguearse por primera vez.
- c. Pantalla de cambio de contraseña cuando se loguea con contraseña
  temporal, con doble confirmación.

### 3. Módulo de Ubicaciones Registradas — 20%
- a. Pantalla de registro de ubicaciones con sus datos esenciales,
  obteniendo la ubicación mediante GPS del teléfono o la API de Google
  Maps (selección manual).
  - i. Las coordenadas de la ubicación deben almacenarse en la base de
    datos.
- b. Edición de ubicaciones registradas y eliminación **en cascada**
  (incluyendo sus actividades).
- c. Pantalla de listado de ubicaciones disponibles creadas en el
  planificador.

### 4. Módulo de Actividades — 30%
- a. Pantalla de listado de actividades creadas según las ubicaciones
  registradas.
  - i. Cada ubicación tiene sus actividades, y debe validarse que **no se
    crucen entre sí** (no solapamiento de horario).
- b. Pantalla de creación de actividades: selección de ubicación,
  descripción, fecha, horario, tipo de actividad (al aire libre o
  interior), y listado de condiciones climáticas deseables para su
  realización.
- c. Pantalla de edición de datos generales de las actividades.
- d. Opción de eliminación de la actividad.

### 5. Módulo de Actividades Pendientes — 30%
- a. Listado de actividades próximas a realizar, con su ubicación asignada
  e información del clima de ese día en esa ubicación (API de Google del
  clima).
- b. Filtros según proximidad de fecha, ubicación, o probabilidad de
  realizarse según el clima.
- c. Opción de marcar una actividad como finalizada.
- d. Opción de reagendar actividad desde esta pantalla.
- e. Indicador de probabilidad de realización por actividad, según el tipo
  de actividad y el clima a presentarse.

## Instrucciones del Proyecto

- El proyecto se trabaja en parejas o de forma individual.
- El código debe estar **documentado**.
- La nota es individual: se califica la capacidad de cada estudiante de
  explicar y defender el código. Cada estudiante debe tener dominio
  completo del código.
- Proyectos con plagio serán anulados.
- Fecha de entrega: una semana antes del examen final de curso.
- Entrega de avances: última semana antes del cierre de zonas finales.

## Ponderación

| Módulo                          | Ponderación |
|----------------------------------|-------------|
| Login                            | 10%         |
| Módulo de Usuario                | 10%         |
| Módulo de Ubicaciones            | 20%         |
| Módulo de Actividades            | 30%         |
| Módulo de Actividades Pendientes | 30%         |

Valor total del proyecto final: **20 pts**.
