#/bin/bash

set -euo pipefail


if [[ -d "$PYTHON_DIR" ]]; then
  rm -rf "$PYTHON_DIR"
fi
mkdir -p "$PYTHON_DIR"
cd "$PYTHON_DIR"


pypyFile="pypy${PYTHON_VERSION}-v${PYPY_VERSION}-linux64"
pypyUrl="https://downloads.python.org/pypy/${pypyFile}.tar.bz2"
tarFile="$PYTHON_DIR/$pypyFile.tar.bz2"

if [[ -e "$tarFile" ]]; then
  tar -xjf "$tarFile"
  rm -rf "$tarFile"
else
  wget -O - "$pypyUrl" | tar -xjf -
fi

mv -n "$pypyFile" pypy


mkdir -p "$PYTHON_DIR/bin/"

cat > "$PYTHON_DIR/bin/python" <<EOF
#!/bin/bash
# the substitution below prepends a colon to library path, hence the `:$var` after the plus
LD_LIBRARY_PATH=$PYTHON_DIR/pypy/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH} exec $PYTHON_DIR/pypy/bin/pypy "\$@"
EOF

chmod +x "$PYTHON_DIR/bin/python"
"$PYTHON_DIR/bin/python" --version
ln -s "$PYTHON_DIR/bin/python" "$PYTHON_DIR/bin/python3"
chmod +x "$PYTHON_DIR/bin/python3"

find "$PYTHON_DIR/" -iname '.bootstrapped_*' -delete
touch "$PYTHON_DIR/.bootstrapped_${PYTHON_VERSION}_$PYPY_VERSION"
