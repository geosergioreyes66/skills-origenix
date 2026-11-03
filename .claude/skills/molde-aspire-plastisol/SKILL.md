---
name: molde-aspire-plastisol
description: Construir en Vectric Aspire 12.5, con el MCP `aspire` (run_lua), el molde 3D invertido de un llavero de PVC blando o plastisol a partir de un diseño de CorelDRAW, con un componente por color y su Desbaste 3D. Úsala siempre que pidan hacer, rehacer o escalar el molde; cambiar profundidades; crear, recalcular o cambiar la fresa de la trayectoria; revisar por qué la simulación o la vista 2D se ven mal; subir la resolución de modelado; pasar el archivo a otra persona o a otra versión de Aspire; o abrir o reparar el puente Claude Bridge, aunque solo digan "vuelve a hacer el molde" o "quedó horrible". Para editar el diseño en Corel, usa diseno-logo-corel.
---

# Molde de plastisol en Aspire

Se trabaja sobre el Aspire abierto del usuario. Claude no ve la pantalla: las vistas 3D y 2D y la simulación solo las puede confirmar el usuario, así que nunca diga que se ven bien sin que él lo haya dicho.

## Antes de construir

1. **Mire el estado.** Con `run_lua`, lea el nombre del trabajo, el bloque (`MaterialBlock().MaterialBox`), las capas y la cantidad de trayectorias. El usuario suele abrir, cerrar o cambiar trabajos por su cuenta.
2. **Si `run_lua` responde que Claude Bridge no escucha,** pídale abrir **Artilugio > Claude Bridge**. El script queda en cola y corre al abrirla: no lo reenvíe, lea `get_bridge_result`. La ventana es modal a propósito: mientras está abierta, él no puede usar Aspire, y la cierra cuando quiere trabajar a mano.
3. **Confirme cuatro datos** si no son evidentes: ancho final del llavero, profundidades, fresa y si el bloque es el correcto. El ancho final decide todo lo demás. Una medida del archivo es la que corta la máquina: la CNC no escala sola.
4. **Avise si el modelo no se puede fabricar**, con la medida real, y deje que él decida. Vea la sección Fabricación.

## Construir el molde

El método es de máscaras, no de vectores: se exporta el diseño de Corel, se clasifica por color y cada color se vuelve un `Relief`. Da componentes limpios sin depender de cómo se solapen las formas.

1. **Exportar de Corel** el PNG del rectángulo exacto del fondo, sin suavizado y transparente:
   ```python
   o = app.CreateStructExportOptions()
   o.ImageType = c.cdrRGBColorImage; o.Transparent = True
   o.ExportArea = app.CreateRect(F.LeftX, F.BottomY, F.SizeWidth, F.SizeHeight)
   o.SizeX = nx; o.SizeY = ny; o.ResolutionX = 72; o.ResolutionY = 72
   o.AntiAliasingType = c.cdrNoAntiAliasing
   d.ExportEx(ruta, c.cdrPNG, c.cdrCurrentPage, o, app.CreateStructPaletteOptions()).Finish()
   ```
   `F` es la forma llamada `Fondo del logo (llavero)`. Puede haber dos con ese nombre: tome la que está dentro de la página. Los 1879 × 2486 px usados dan 0.07 mm/px a 131.5 mm y 0.026 mm/px a 48.2 mm.
2. **Generar las máscaras** con `scripts/mascaras.py`. Falla si queda un color sin clasificar: decida a qué clase va y agréguelo a la paleta. Antes de clasificar, pregúntese qué es cada color nuevo: un contorno agregado por el usuario puede ser una pared, no una zona.
   ```bash
   python "C:\Users\Sergio reyes\.claude\skills\molde-aspire-plastisol\scripts\mascaras.py" entrada.png "C:\Users\Sergio reyes\aspire-mcp\bridge\molde"
   ```
3. **Crear los componentes y la trayectoria** con `scripts/construir_molde.lua`: copie su contenido a `run_lua`, ajuste los valores de arriba y use `wait_seconds` de 400 o más.
4. **Pida al usuario revisar** la Vista 3D y la simulación. Con la argolla arriba a la derecha en el diseño, en el molde debe quedar arriba a la izquierda y el texto al revés.
5. **Diga qué quedó sin guardar.** No guarde sin que lo pidan.

Para cambiar profundidades o tamaño, se quitan todos los componentes y se rehacen con las mismas máscaras: el script ya lo hace. La trayectoria se rehace siempre, porque queda calculada sobre el modelo viejo.

## Las decisiones de este proyecto

| | |
|---|---|
| **Cavidad** | Modo Restar: el cuerpo se hunde y cada color se hunde más sobre él |
| **Cuerpo negro** | 3.0 mm |
| **Colores** | 1.0 mm bajo el cuerpo, 4.0 mm en total. Con 0.5 mm el relieve quedaba plano frente a la foto de referencia |
| **Contornos oscuros** (`#373435`, `#000000`) | Se quedan a la altura del cuerpo: son las paredes entre colores |
| **Espejo** | Sí. El script lo aplica a las máscaras, no al diseño |
| **Bloque** | Cerca de 12 mm más ancho y 21 mm más alto que el llavero (60 × 85 × 8 mm para 48.2 mm) |
| **Desbaste 3D** | Raster en X, sobreespesor 0, Z segura 2 mm |
| **Velocidades** | Son de prueba. Quien mecaniza debe fijarlas según su máquina y el material |

Los datos del llavero y los archivos están en `references/llavero-origenix.md`.

## Fabricación

| A 48.2 mm de ancho | Medida | Consecuencia |
|---|---|---|
| Subtítulo | Trazo de unos 0.4 mm | Una fresa de 0.79 mm no entra: las letras desaparecen de la simulación |
| Líneas finas entre colores | 0.07 mm | No se mecanizan ni separan el plastisol. Mínimo razonable: 0.3 mm |
| Fresa para el detalle | 0.3 mm, pasos de 0.1 mm | Posible con husillo de 18 000 a 24 000 rpm y máquina firme. Lenta. Confirme con el taller |

**El usuario juzga por la imagen.** Si dice "quedó horrible", separe primero qué está viendo: el modelo o la simulación. Las versiones a 48 mm con fresa de 0.79 o 0.3 mm y con líneas de 0.4 mm le parecieron feas, y pidió volver al modelo de 131.5 mm. Conserve esa versión antes de intentar otra, y no vuelva a ofrecer lo que ya rechazó sin decir qué cambió.

## Preguntas que ya salieron

- **Vista 2D gris sin detalle:** es normal. Muestra la vista previa de los componentes, y el del cuerpo tapa a los demás. No afecta el mecanizado. Para ver líneas hay que importar los vectores.
- **Líneas gruesas y escalonadas en 3D:** es la resolución del trabajo. Se cambia en el primer icono de **Operaciones con archivos** (Configuración del material) > **Resolución de modelado** > **Muy alto**. Con 4 millones de puntos en 144.8 × 191.6 mm, cada punto mide unos 0.08 mm.
- **Pasar a otra versión de Aspire (la 10.5):** la ayuda no ofrece guardar para una versión anterior. **Guardar como** solo da `.CrV` de VCarve, que elimina los datos 3D. Salidas: **Modelo > Exportar como STL**, con tolerancia pequeña, para que la otra persona haga su trayectoria; o **Guardar trayectorias** con el postprocesador de su máquina. El tamaño sale igual al del trabajo: revíselo antes de enviar.

## Trampas de la API (comprobadas)

- **`SaveCurrentJobAs` seguido de `ForceCloseCurrentJob(false)` no cerró el trabajo.** `CreateNewJob` devolvió `false` sin error y el script siguió: metió los componentes nuevos en el trabajo viejo. Compruebe el retorno de `CreateNewJob` y aborte si es `false`. No encadene guardar, cerrar y crear en un solo script.
- **Un segundo `ForceCloseCurrentJob` dejó el puente en espera,** seguramente con un diálogo de guardar abierto. Pida al usuario revisar Aspire; no reenvíe.
- **`CreateNewJob` falla si hay un trabajo abierto.** Antes de cerrar uno, compruebe que está vacío o que el usuario aceptó perderlo.
- **Cambiar la resolución de modelado hizo desaparecer el modelo:** los componentes siguen en la capa, pero la vista queda vacía. Hay que rehacerlos y recalcular la trayectoria. Avísele antes de que la cambie.
- **La API no cambia el material ni la resolución.** `MaterialBlock` es de solo lectura. Para otro bloque, cree otro trabajo o pídale el cambio al usuario.
- **Los componentes se quitan con `layer:RemoveObject(obj)`** sobre los objetos `vcCadModelPreview`. No hay forma confiable de elegir uno por nombre.
- **`selection:Transform` con varios objetos solo transforma el primero.** Transforme uno por uno: `sel:Clear()`, `sel:Add(o, true, false)`, `sel:Transform(m)`.
- **Mover objetos entre capas falla.** Para separar por capas, importe un DXF con `job:ImportDxfDwg(ruta)`.
- **`CreateRoughingToolpath` devuelve de inmediato y no hay manera de leer sus cortes.** "Creada" no prueba que tenga líneas: pídale revisar la vista previa.
- **`ForceCloseCurrentJob` exige el parámetro bool.**
- **Rutas de más de 260 caracteres:** los PNG que el usuario pega viven en carpetas temporales largas. En PowerShell use el prefijo `\\?\`.
