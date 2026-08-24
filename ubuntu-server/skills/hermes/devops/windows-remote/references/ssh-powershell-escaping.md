# SSH → PowerShell escaping: el triple bash→ssh→powershell

Detalles técnicos del problema de escaping al ejecutar PowerShell remoto por SSH desde un shell Linux. Verificado el 2026-07-25 contra `YOUR_HOSTNAME` (Windows 11 Enterprise, OpenSSH for Windows).

## Las tres capas

Cuando ejecutas, desde Hermes en Linux:

```
bash    →  ssh    →  powershell.exe -Command "..."
```

el string pasa por TRES intérpretes que reinterpreta caracteres:

1. **Bash** (capa local): procesa `"`, `'`, `$VAR`, `\`, `` ` ``, `*`, etc. Solo el string entre comillas simples `'...'` pasa literal a ssh.
2. **SSH/OpenSSH** (transporte): pasa el argumento al proceso remoto casi sin tocar, pero la forma en que argv se reconstruye en el lado Windows depende del cliente y del servidor SSH. OpenSSH for Windows reconstruye la línea de comandos según sus reglas de quoting (no POSIX, no cmd nativo).
3. **PowerShell** (ejecución remota): recibe el `-Command "..."` y aplica SU parser. En PowerShell, las comillas dobles activan expansión de variables (`$_`, `$env:X`), y el backslash NO es escape de carácter (no como en C o bash).

## Qué falla en cada capa

### Backslash `\`

- **PowerShell**: lo trata literal. `D:\ing-sistemas` es una ruta válida.
- **Bash con comillas dobles**: preserva `\` en la mayoría de casos pero hay contextos (`echo "a\b"` → `a\b`) donde lo deja. `\\"` dentro de `"..."` en bash SÍ colapsa a `\"`.
- **Resultado real**: si envuelves el comando PowerShell en comillas dobles bash y pones `D:\\ing-sistemas`, PowerShell recibe `D:\ing-sistemas` (correcto) PERO los `\"` intermedios colapsan mal. Por eso rutas con backslash se envían con comillas simples bash + dobles PowerShell.

### Comillas dobles `"`

- **PowerShell**: activan interpolación de variables. `"$_"` expande; `'$_'` no.
- **Bash con comillas dobles**: `"\""` produce `"`. Así que `"... \"Get-ChildItem\" ..."` bash lo pasa a ssh como `... "Get-ChildItem" ...`.
- **SSH capa Windows**: cuando hay comillas anidadas, OpenSSH for Windows puede reconstruir mal la línea. Resultado típico: PowerShell reporta `TerminatorExpectedAtEndOfString` o `Debe proporcionar una expresión de valor después del operador`.

### Dolar `$`

- **PowerShell**: inicio de variable. `$_`, `$env:X`, `$d.Free`.
- **Bash con comillas dobles**: `$VAR` expande. Si escribes `$_` entre dobles bash, bash lo expande a PID del shell actual O lo deja si la variable no está set. Impredecible.
- **Regla**: variables PowerShell (`$_`, `$env:`) SIEMPRE van entre comillas simples bash, para que bash no las toque.

### Pipe `|`

- **PowerShell**: operador de pipeline.
- **Bash**: operador de pipe también. Si el `-Command "..."` PowerShell está entre comillas dobles bash y contiene `|`, bash NO lo interpreta porque está dentro del string. Entre comillas simples bash: idem, literal.
- **Trampa**: dentro de una tabla de ejemplo o bloque de documentación, `|` puede romper la tabla Markdown. Escápalo como `\|` solo en el texto de docs, no en el comando real.

## Patrones que SÍ funcionan

### Patrón A: comando simple, comillas simples bash + dobles PowerShell

```bash
ssh -i ~/.ssh/YOUR_WIN_SSH_KEY krailynd@YOUR_TAILSCALE_IP \
  'powershell.exe -NoProfile -Command "Test-Path D:\ing-sistemas"'
```

Bash pasa todo el string `'...'` literal a ssh. Ssh lo pasa a powershell. PowerShell parsea el `-Command "..."` y ejecuta. Funciona para UN comando sin comillas anidadas.

### Patrón B: múltiples comandos con `;`

```bash
ssh ... 'powershell.exe -NoProfile -Command "$env:COMPUTERNAME; $env:USERNAME; Get-Date -Format yyyy-MM-dd"'
```

Las `$` están dentro de comillas simples bash → pasan literales → PowerShell las expande. OK.

### Patrón C: script complejo por stdin

Para scripts multi-línea, escribirlos en Linux y subirlos por stdin evita TODO el problema de escaping:

```bash
# Escribir el script PowerShell nativo (sin escapar) en /tmp/probe.ps1
# Luego:
cat /tmp/probe.ps1 | ssh -o BatchMode=yes -o ConnectTimeout=15 \
  -i ~/.ssh/YOUR_WIN_SSH_KEY krailynd@YOUR_TAILSCALE_IP \
  "powershell.exe -NoProfile -Command -"
```

PowerShell lee el script completo de stdin. No hay стек de escaping.

### Patrón D: EncodedCommand (base64 UTF-16LE)

```bash
# Generar base64 UTF-16LE (no UTF-8):
iconv -t UTF-16LE /tmp/script.ps1 | base64 -w0
# Pasar a powershell:
ssh ... "powershell.exe -NoProfile -EncodedCommand <base64>"
```

Elude todo escaping. Útil para scripts largos donde stdin falla. Caveat: el base64 debe ser UTF-16LE porque PowerShell espera esa codificación por defecto para EncodedCommand. El `base64` plano de Linux produce UTF-8 base64 y PowerShell puede mostrar warnings.

## Qué NO usar

- `scp`: subsistema SFTP desactivado en ese OpenSSH for Windows → "subsystem request failed on channel 0".
- `ssh host "comando"` sin `powershell.exe -` explícito: cae en cmd, PowerShell cmdlets no reconocidos.
- `ssh windows-krai "comando"` para scripting: el `RemoteCommand` del config se antepone y rompe.
- Anidar `\"` `\\` a mano en scripts de más de 2 líneas: inmanejable.
