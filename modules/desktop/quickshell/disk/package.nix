{ writeShellScriptBin, python3 }:
writeShellScriptBin "qs-filesystems" ''
  exec ${python3}/bin/python3 ${./filesystems.py}
''
