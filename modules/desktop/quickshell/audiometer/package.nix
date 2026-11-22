{ writeShellScriptBin, python3, pulseaudio }:
writeShellScriptBin "qs-audiometer" ''
  export QS_PAREC=${pulseaudio}/bin/parec
  exec ${python3}/bin/python3 ${./audiometer.py} "$@"
''
