# Molde del llavero ORIGENIX

Datos a noviembre de 2026. Revíselos contra los archivos antes de usarlos: el usuario cambia cosas por su cuenta.

## Archivos

| Archivo | Qué es |
|---|---|
| `C:\Users\Sergio reyes\Desktop\llavero.cdr` | Diseño en CorelDRAW. Fondo de 5.70 × 7.54 pulgadas de documento, que son 48.2 × 63.8 mm reales |
| `D:\Nueva carpeta (2)\Trabajo\ORIGENIX\llavero\molde\Molde llavero grande 131mm.crv3d` | El molde que le gustó, a 131.5 × 174 mm |
| `...\molde\Molde llavero ORIGENIX.crv3d` | Molde viejo. No es el bueno |
| `...\molde\Plano llavero con medidas.png` | Captura con las cotas a tamaño final |
| `C:\Users\Sergio reyes\aspire-mcp\bridge\molde\*.txt` | Las últimas máscaras. Se generaron de una exportación posterior a `molde_colores.png`, así que antes de usarlas exporte de nuevo desde Corel y regenérelas |

## Medidas para `construir_molde.lua`

| | Modelo grande | Tamaño real |
|---|---|---|
| Bloque | 144.78 × 191.586 × 8 mm, esquina en −79.3297, −77.3343 | 60 × 85 × 8 mm, esquina en −30, −42.5 |
| `ANCHO` | 131.513132 | 48.2 |
| `X0, Y0` | −72.853353, −68.275057 | −24.1, −31.885 |
| Escala de diseño | 23.072 mm por pulgada de documento | 8.456 mm por pulgada de documento |

## Colores

Cuerpo `#0A0C0B`; blanco `#FFFFFF` y `#FEFEFE`; verde `#80D15A`, con contorno `#85C55C`; café oscuro `#603813`; café `#8C6239`; terracota `#D6582D`; naranja `#F7931E`. Contorno de paredes `#373435`; contorno de letras `#000000`.

## Historia

1. Modelo de 131.5 mm, colores a 0.5 mm: le gustó.
2. A 48.2 mm con colores a 1.0 mm y líneas de 0.4 mm: "quedó horrible". Era la simulación con fresa de 0.79 mm.
3. Con fresa de 0.3 mm, otra vez a 48.2 mm: "súper horrible". Pidió volver al primero.
4. Modelo de 131.5 mm con colores a 1.0 mm y resolución "Muy alto": aceptado.
5. Para el taller se quiere un llavero de 4.8 × 6.4 cm. Pendiente: la persona de la CNC tiene Aspire 10.5, y el trabajo a tamaño real no ha quedado creado por separado.
