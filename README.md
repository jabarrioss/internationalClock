# World Clocks - Aplicación de Relojes Múltiples

Una aplicación de escritorio creada con AutoIT que te permite tener múltiples relojes con diferentes zonas horarias en tu escritorio, similar al gadget de relojes de Windows 7.

## Características

### 🕐 Relojes Digitales
- Pantalla digital moderna con horas, minutos y segundos
- 3 skins diferentes:
  - **Modern Dark** (0): Fondo oscuro con acentos azules
  - **Classic** (1): Estilo clásico con fondo claro
  - **Colorful** (2): Diseño colorido con tonos vibrantes

### 🕐 Relojes Análogos
- Reloj análogo tradicional con manecillas para horas, minutos y segundos
- 3 skins diferentes:
  - **Modern** (0): Estilo moderno oscuro con detalles azules
  - **Classic** (1): Diseño clásico con fondo blanco
  - **Elegant** (2): Elegante negro con detalles dorados

### ✨ Funcionalidades
- ✅ Múltiples relojes simultáneos
- ✅ Configuración de zona horaria personalizada para cada reloj
- ✅ Arrastrar y soltar para reposicionar
- ✅ Guardado automático de configuración
- ✅ Menú contextual (click derecho) en cada reloj para:
  - Cambiar zona horaria
  - Cambiar skin/estilo
  - Eliminar reloj
- ✅ Menú en system tray para agregar nuevos relojes
- ✅ Siempre visible (topmost)

## Requisitos

- **AutoIT v3**: [Descargar desde autoitscript.com](https://www.autoitscript.com/site/autoit/downloads/)
- **Sistema Operativo**: Windows 7 o superior

## Instalación

1. Instala AutoIT si aún no lo tienes
2. Descarga el archivo `WorldClocks.au3`
3. Ejecuta el script con AutoIT

### Compilar a ejecutable (opcional)

1. Click derecho en `WorldClocks.au3`
2. Selecciona "Compile Script to .exe"
3. Ejecuta `WorldClocks.exe`

## Uso

### Iniciar la Aplicación
- Ejecuta el script o el ejecutable compilado
- La aplicación iniciará con dos relojes por defecto (si es la primera vez)
- El ícono aparecerá en el system tray

### Agregar Nuevo Reloj

**Desde el System Tray:**
1. Click derecho en el ícono de la aplicación en el system tray
2. Selecciona "Add Digital Clock" o "Add Analog Clock"
3. Ingresa el nombre de la ciudad
4. Ingresa el offset de zona horaria (ej: -5 para EST, +1 para CET, +9 para JST)
5. Selecciona el estilo de skin (0, 1 o 2)

### Mover un Reloj
- Mantén click izquierdo y arrastra el reloj a la posición deseada
- La posición se guarda automáticamente

### Configurar un Reloj
1. Click derecho en el reloj
2. Selecciona:
   - **Change Timezone**: Cambiar la zona horaria
   - **Change Skin**: Cambiar el estilo visual
   - **Remove Clock**: Eliminar el reloj

### Cerrar la Aplicación
- Click derecho en el ícono del system tray
- Selecciona "Exit"

## Zonas Horarias Comunes

| Ciudad | Offset UTC |
|--------|-----------|
| Los Angeles (PST) | -8 |
| Denver (MST) | -7 |
| Chicago (CST) | -6 |
| New York (EST) | -5 |
| Buenos Aires | -3 |
| London (GMT) | 0 |
| Paris (CET) | +1 |
| Cairo | +2 |
| Moscow | +3 |
| Dubai | +4 |
| Mumbai | +5.5 |
| Bangkok | +7 |
| Shanghai | +8 |
| Tokyo | +9 |
| Sydney | +10 |

## Configuración

La configuración se guarda automáticamente en `clocks.ini` en el mismo directorio del script. Este archivo almacena:
- Número de relojes
- Tipo de cada reloj (digital/análogo)
- Zona horaria
- Nombre de la ciudad
- Posición X, Y
- Estilo de skin

## Características Técnicas

- **Lenguaje**: AutoIT 3
- **Renderizado**: GDI+ para gráficos suaves y antialiasing
- **Transparencia**: Ventanas con transparencia y siempre al frente
- **Actualización**: Cada segundo
- **Persistencia**: Archivo INI para configuración

## Solución de Problemas

**Los relojes no aparecen:**
- Verifica que AutoIT esté instalado correctamente
- Ejecuta el script como administrador si es necesario

**La hora no es correcta:**
- Verifica el offset de zona horaria
- El offset se basa en UTC (Tiempo Universal Coordinado)

**El reloj no se puede arrastrar:**
- Asegúrate de hacer click izquierdo y mantener presionado
- El cursor debe estar sobre el reloj

## Personalización

Puedes modificar el código para:
- Cambiar los colores de los skins
- Agregar más estilos de skins
- Modificar el tamaño de los relojes
- Cambiar las fuentes
- Agregar más funcionalidades

## Licencia

Este proyecto es de código abierto y puede ser modificado libremente para uso personal.

## Autor

Creado con AutoIT - Una solución simple y efectiva para gestionar múltiples zonas horarias en tu escritorio.

---

**¡Disfruta de tus relojes mundiales!** 🌍🕐
