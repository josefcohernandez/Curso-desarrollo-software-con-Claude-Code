#!/usr/bin/env python3
"""Comprueba que los enlaces relativos de los Markdown versionados apuntan a ficheros que existen.

Ignora URLs con esquema (http:, mailto:…), anclas sueltas, bloques de código, código en línea y
comentarios HTML. Los enlaces que salen del repo (../ desde la raíz) apuntan al monorepo
cursos-libros-ia, del que este curso es submódulo, y no se pueden comprobar aquí.
No comprueba anclas (#sección) ni enlaces externos: tiene que ser rápido y no usar la red.
"""
import os
import re
import subprocess
import sys
import urllib.parse

ENLACE = re.compile(r'!?\[[^\]]*\]\(\s*<?([^)\s>]+)>?(?:\s+"[^"]*")?\s*\)')
ESQUEMA = re.compile(r"^[a-z][a-z0-9+.-]*:", re.I)

raiz = os.path.realpath(os.getcwd())
ficheros = subprocess.run(
    ["git", "ls-files", "-z", "*.md"], capture_output=True, text=True, check=True
).stdout.split("\0")

rotos, n = [], 0
for f in filter(None, ficheros):
    en_codigo = en_comentario = False
    with open(f, encoding="utf-8") as fh:
        for i, linea in enumerate(fh, 1):
            if linea.lstrip().startswith(("```", "~~~")):
                en_codigo = not en_codigo
                continue
            if en_codigo:
                continue
            linea = re.sub(r"<!--.*?-->", "", linea)
            if en_comentario:
                if "-->" not in linea:
                    continue
                en_comentario, linea = False, linea.split("-->", 1)[1]
            if "<!--" in linea:
                en_comentario, linea = True, linea.split("<!--", 1)[0]
            for destino in ENLACE.findall(re.sub(r"`[^`]*`", "", linea)):
                if ESQUEMA.match(destino) or destino.startswith("#"):
                    continue
                ruta = urllib.parse.unquote(destino.split("#", 1)[0])
                if not ruta:
                    continue
                completa = os.path.realpath(os.path.join(os.path.dirname(f), ruta))
                if not completa.startswith(raiz + os.sep):
                    continue  # fuera del repo: monorepo padre
                n += 1
                if not os.path.exists(completa):
                    rotos.append(f"{f}:{i}: {destino}")

if rotos:
    print("Enlaces rotos:", *rotos, sep="\n  ")
    sys.exit(1)
print(f"{n} enlaces relativos comprobados")
