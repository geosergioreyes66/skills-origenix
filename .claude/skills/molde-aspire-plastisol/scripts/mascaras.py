"""Convierte el PNG del llavero en una mascara por color para construir_molde.lua.

Uso: python mascaras.py entrada.png carpeta_salida

Cada archivo tiene una linea por fila, de abajo hacia arriba, con pares
"inicio largo" de pixeles. Las mascaras salen en espejo horizontal.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

# Colores que quedan a la altura del cuerpo: el negro y las paredes entre colores.
NEGROS = [0x0A0C0B, 0x000000, 0x373435]
COLORES = {
    "blanco": [0xFFFFFF, 0xFEFEFE],
    "verde": [0x80D15A, 0x85C55C],
    "cafe_oscuro": [0x603813],
    "cafe": [0x8C6239],
    "terracota": [0xD6582D],
    "naranja": [0xF7931E],
}


def runs(fila):
    d = np.diff(np.concatenate([[0], fila.astype(np.int8), [0]]))
    inicios, fines = np.where(d == 1)[0], np.where(d == -1)[0]
    return " ".join(f"{a} {b - a}" for a, b in zip(inicios, fines))


def main(entrada, salida):
    a = np.array(Image.open(entrada).convert("RGBA")).astype(int)
    opaco = a[..., 3] > 127
    rgb = (a[..., 0] << 16) | (a[..., 1] << 8) | a[..., 2]

    conocidos = NEGROS + [c for lista in COLORES.values() for c in lista]
    resto = opaco & ~np.isin(rgb, conocidos)
    if resto.any():
        valores, cuentas = np.unique(rgb[resto], return_counts=True)
        detalle = ", ".join(f"#{v:06X} ({c} px)" for v, c in zip(valores, cuentas))
        sys.exit(f"Colores sin clasificar: {detalle}. Agreguelos a NEGROS o COLORES.")

    salida = Path(salida)
    salida.mkdir(parents=True, exist_ok=True)
    print(f"imagen {a.shape[1]} x {a.shape[0]} px")
    clases = {"negro": opaco, **{k: opaco & np.isin(rgb, v) for k, v in COLORES.items()}}
    for nombre, mascara in clases.items():
        m = np.flipud(np.fliplr(mascara))
        (salida / f"{nombre}.txt").write_text("\n".join(runs(f) for f in m) + "\n")
        print(nombre, int(m.sum()))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
