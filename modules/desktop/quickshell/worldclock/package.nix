{ writeShellScriptBin, python3, tzdata }:
writeShellScriptBin "qs-worldclock" ''
  export PYTHONTZPATH=${tzdata}/share/zoneinfo
  exec ${python3}/bin/python3 ${./worldclock.py}
''
