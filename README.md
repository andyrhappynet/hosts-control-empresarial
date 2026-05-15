# 🛡️ Hosts Control Empresarial

Sistema centralizado de control de acceso web mediante archivo `hosts` de Windows.
Permite bloquear sitios web por departamento, actualizado automáticamente desde GitHub.

---

## 📁 Estructura del Repositorio

```
hosts-control-empresarial/
│
├── hosts/
│   ├── hosts-ventas.txt          # Hosts para Ventas
│   ├── hosts-retention.txt       # Hosts para Retention
│   ├── hosts-calidad.txt         # Hosts para Calidad
│   └── hosts-administracion.txt  # Hosts para Administración
│
├── INSTALAR-COMO-ADMIN.bat       # Instalador único (ejecutar 1 sola vez)
├── FORZAR-UPDATE-ADMIN.bat       # Forzar actualización manual
└── README.md
```

---

## 🚀 Cómo Funciona

1. **El admin ejecuta** `INSTALAR-COMO-ADMIN.bat` **una sola vez** en cada equipo.
2. El instalador configura tareas programadas en Windows que corren como `SYSTEM`.
3. Los hosts se descargan automáticamente desde este repositorio.
4. Los usuarios estándar **nunca necesitan permisos de admin** para las actualizaciones.

### Frecuencia de actualización
- ✅ Al iniciar el equipo (con 1 minuto de delay para que haya red)
- ✅ Cada N horas (configurable durante la instalación, recomendado: 4h)
- ✅ Forzado manual con `FORZAR-UPDATE-ADMIN.bat`

---

## 🔧 Instalación en un Equipo Nuevo

### Paso 1 — Descargar el instalador
Descarga `INSTALAR-COMO-ADMIN.bat` desde este repositorio.

### Paso 2 — Ejecutar como Administrador
```
Clic derecho → "Ejecutar como administrador"
```

### Paso 3 — Seguir el asistente
El instalador preguntará:
- Departamento del equipo (Ventas / Retention / Calidad / Administración)
- Tu usuario de GitHub
- Nombre de este repositorio
- Cada cuántas horas actualizar

### Paso 4 — Listo 🎉
El sistema queda instalado. No se vuelve a tocar el equipo.

---

## ✏️ Cómo Actualizar los Hosts Bloqueados

1. Edita el archivo `.txt` del departamento correspondiente en la carpeta `hosts/`
2. Haz commit y push a la rama `main`
3. Los equipos se actualizarán automáticamente en el próximo ciclo (o al reiniciar)
4. Para actualización inmediata en un equipo: ejecutar `FORZAR-UPDATE-ADMIN.bat`

---

## 📋 Formato de los Archivos Hosts

```
# Comentario
127.0.0.1 localhost
::1 localhost

# Sitios bloqueados
0.0.0.0 facebook.com
0.0.0.0 www.facebook.com
```

**Importante:** Para bloquear un dominio, añade tanto el dominio raíz como `www.`:
```
0.0.0.0 ejemplo.com
0.0.0.0 www.ejemplo.com
```

---

## 📂 Archivos de Sistema Instalados

En cada equipo, el instalador crea:
```
C:\HostsControl\
├── config.ini              # Configuración del equipo
├── FORZAR-UPDATE.bat       # Acceso directo al forzado
├── scripts\
│   └── update-hosts.bat    # Script principal de actualización
├── logs\
│   └── update.log          # Registro de todas las actualizaciones
└── backups\
    └── hosts_backup_*.txt  # Últimos 30 backups automáticos
```

---

## 🔒 Seguridad

- El archivo `hosts` en los equipos está **protegido** — usuarios estándar no pueden modificarlo.
- Los scripts corren como `SYSTEM` via Tareas Programadas de Windows.
- El repositorio debe ser **público** (o usar token de acceso para repos privados).
- Cada actualización reemplaza el hosts **en su totalidad** — no agrega líneas.
- Se mantienen automáticamente los últimos **30 backups** en cada equipo.

---

## 🛟 Resolución de Problemas

| Problema | Solución |
|---|---|
| No se actualiza el hosts | Revisar `C:\HostsControl\logs\update.log` |
| Tarea programada no existe | Re-ejecutar `INSTALAR-COMO-ADMIN.bat` |
| El repositorio no es accesible | Verificar que el repo es público |
| Hosts no bloquea un sitio | Asegurarse de agregar `www.` también |

---

## 📞 Soporte

Para cualquier consulta, revisar primero el archivo de log:
```
C:\HostsControl\logs\update.log
```
