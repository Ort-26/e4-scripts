# e4-scripts

Scripts de inicialización y configuración de la base de datos PostgreSQL para el sistema de soporte de tickets E4.

## Descripción

Este conjunto de scripts automatiza la creación de la estructura de base de datos, tablas, funciones, catálogos, permisos y datos iniciales necesarios para que funcione el sistema E4. Incluye la generación de un archivo maestro (`global.sql`) que unifica todos los scripts en el orden correcto.

## Estructura del proyecto

```
e4-scripts/
├── README.md                 # Este archivo
├── create-global.js          # Script Node.js que genera global.sql
├── global.sql                # Archivo SQL maestro generado (salida)
│
├── tables/
│   └── allTables.sql         # Definición de todas las tablas
│
├── functions/                # (vacío, reservado para funciones SQL)
│
├── inserts/
│   ├── A0 - catalogs.sql     # Inserciones de catálogos (status, roles, permisos)
│   ├── B1-Permissions.sql    # Asignación de permisos a roles
│   ├── mock-data.sql         # Datos de prueba opcionales
│   └── U1 - users.sql        # Usuarios iniciales
│
├── db-user/
│   └── user.sql              # Creación del usuario de aplicación y permisos
│
└── common/
    └── scripts.sql           # Scripts comunes (si los hubiera)
```

## Contenido de cada sección

### 1. **tables/** - Definición de estructura

Define todas las tablas de la base de datos:

- **Catálogos base:** `cat_permissions`, `cat_roles`, `cat_ticket_statuses`
- **Maestras:** `mas_users`, `mas_tickets`, `mas_comments`
- **De control:** `ctl_roles_permissions`, `ctl_ticket_status_transitions`
- **Intermedias:** `mas_tickets_mas_users`, `mas_tickets_comments`
- **De historial:** `his_ticket_status_changes`, `his_assignation_changes`

### 2. **functions/** - Funciones SQL

Carpeta reservada para funciones y procedimientos almacenados (actualmente vacía).

### 3. **inserts/** - Datos iniciales

- **A0 - catalogs.sql:** Catálogos base con status de tickets, roles (CLIENT, AGENT, ADMIN) y permisos disponibles
- **B1-Permissions.sql:** Mapeo de permisos a roles para control de acceso
- **mock-data.sql:** Datos de prueba opcionales
- **U1 - users.sql:** Usuarios iniciales

### 4. **db-user/** - Configuración de usuario

Crea el usuario de aplicación (`app_user`) con permisos específicos:
- Lectura en catálogos
- Lectura de usuarios (autenticación)
- Lectura/escritura en tickets y comentarios
- Inserción en tablas de historial

### 5. **common/** - Scripts compartidos

Disponible para scripts comunes que se reutilicen en varias secciones.

## Cómo usar

### Opción 1: Generar y ejecutar global.sql (recomendado)

1. **Genera el archivo maestro:**
   ```bash
   node create-global.js
   ```
   Esto genera `global.sql` que contiene todos los scripts ordenados.

2. **Ejecuta el SQL en PostgreSQL:**
   ```bash
   psql -U postgres -d e4-support-db -f global.sql
   ```

   O desde el cliente de PostgreSQL:
   ```sql
   \i /ruta/a/global.sql
   ```

### Opción 2: Ejecutar scripts individuales

```bash
# 1. Crear tablas
psql -U postgres -d e4-support-db -f tables/allTables.sql

# 2. Insertar catálogos
psql -U postgres -d e4-support-db -f inserts/A0\ -\ catalogs.sql

# 3. Asignar permisos
psql -U postgres -d e4-support-db -f inserts/B1-Permissions.sql

# 4. Crear usuario de aplicación
psql -U postgres -d e4-support-db -f db-user/user.sql
```

## Requisitos

- PostgreSQL 12 o superior
- Acceso de usuario administrador a la base de datos
- Node.js 14+ (solo para regenerar `global.sql`)

## Variables a configurar

Antes de ejecutar los scripts, ajusta según tu entorno:

- **Base de datos:** `e4-support-db` (cambiar en los comandos si es diferente)
- **Usuario de aplicación:** `app_user` (en `db-user/user.sql`)
- **Contraseña:** `app_secure_password` (en `db-user/user.sql`) ⚠️ CAMBIAR en producción

## Roles y permisos

El sistema define tres roles:

### CLIENT
- Crear tickets (`TICKET_CREATE`)
- Leer propios tickets (`TICKET_READ_OWN`)
- Responder cuando se solicita info (`TICKET_CLIENT_RESPOND`)
- Cerrar tickets (`TICKET_CLOSE`)
- Agregar comentarios (`TICKET_COMMENT`)
- Reabrir tickets (`TICKET_REOPEN`)

### AGENT
- Leer todos los tickets (`TICKET_READ_ALL`)
- Iniciar trabajo (`TICKET_START_PROGRESS`)
- Solicitar información del cliente (`TICKET_REQUEST_CLIENT_INFO`)
- Resolver tickets (`TICKET_RESOLVE`)
- Agregar comentarios (`TICKET_COMMENT`)

### ADMIN
- Todos los permisos del sistema

## Flujo de generación de global.sql

El script `create-global.js`:

1. Busca archivos `.sql` en: `tables/`, `functions/`, `inserts/`, `db-user/`
2. Los ordena alfabéticamente dentro de cada sección
3. Agrega comentarios de separación y referencias de archivos
4. Genera el archivo `global.sql` consolidado
5. Imprime el tamaño del archivo generado

Ejemplo de salida:
```
global.sql generated successfully (45823 bytes)
```

## Datos iniciales

El script `A0 - catalogs.sql` crea:

- **6 estados de ticket:** CREATED, ASSIGNED, IN_PROGRESS, WAITING_FOR_CLIENT, RESOLVED, CLOSED
- **3 roles:** CLIENT, AGENT, ADMIN
- **12 permisos:** Operaciones básicas de tickets y comentarios

El archivo `B1-Permissions.sql` asigna automáticamente los permisos a cada rol según su propósito.

## Notas importantes

- Los scripts usan `ON CONFLICT DO NOTHING` para evitar errores en ejecuciones repetidas
- Las IDs se generan con `SERIAL` (auto-incrementales)
- Los timestamps usan `CURRENT_TIMESTAMP` para mantener auditoría
- El usuario de aplicación tiene permisos granulares limitados por seguridad
- Modifica los permisos en `db-user/user.sql` según tus necesidades

## Mantenimiento

Para agregar nuevas tablas, funciones o datos iniciales:

1. Crea el archivo `.sql` en la carpeta correspondiente
2. Sigue la nomenclatura: `A0-`, `B1-`, `U1-` para establecer orden
3. Ejecuta `node create-global.js` para regenerar `global.sql`
4. Verifica y ejecuta el nuevo archivo

## Soporte

Para consultas sobre la estructura de base de datos, revisa:
- Los comentarios en `tables/allTables.sql` para la lógica de tablas
- Los comentarios en `inserts/B1-Permissions.sql` para la lógica de permisos
- Los comentarios en `db-user/user.sql` para los permisos de usuario
