#!/bin/sh

BREWDIR="/usr/local/Cellar/"
QUVIVERSION="0.4.1"
LUAVERSION="5.1.4"

# Check if we have homebrew
if which brew >/dev/null; then
  continue
else
  echo "ERROR: Homebrew is not installed, get it here:\nhttp://mxcl.github.com/homebrew/"
  exit
fi

# Check for libquvi
if [ -d $BREWDIR/libquvi ]; then
  continue
else
  echo "ERROR: libquvi isn't installed, install it using Homebrew:\n$ brew instal libquvi"
fi

# Check for lua
if [ -d $BREWDIR/lua ]; then
  continue
else
  echo "ERROR: lua isn't installed, install it using Homebrew:\n$ brew instal lua"
fi

# Fetch dylibs
if [ -f ./libquvi.*.dylib ] && [ -f ./liblua.*.dylib ]; then
  continue
else
  cp /usr/local/Cellar/libquvi/$QUVIVERSION/lib/libquvi.*.dylib .
  cp /usr/local/Cellar/lua/$LUAVERSION/lib/liblua.$LUAVERSION.dylib .
fi

# Check if that worked
if [ -f ./libquvi.*.dylib ] && [ -f ./liblua.*.dylib ]; then
  continue
else
  echo "cp /usr/local/Cellar/libquvi/$QUVIVERSION/lib/libquvi.*.dylib ."
  echo "cp /usr/local/Cellar/lua/$LUAVERSION/lib/liblua.$LUAVERSION.dylib ."
  echo "ERROR: Couldn't copy libquvi and liblua dylibs."
fi

# Show current dylibs paths
echo "Current dylib paths:"
otool -L lib*.dylib

echo "Unless you altered permissions, you might need to enter your password."

# Loop through files and change path
LIBLUA=""
LIBQUVI=""
for f in `ls lib*.dylib`; do
  if [[ $f == liblua* ]]; then
    LIBLUA=$f
    echo "Changing lua dylib"
    sudo install_name_tool -id @executable_path/../Frameworks/$f $f
  elif [[ $f == libquvi* ]]; then
    LIBQUVI=$f
    echo "Changing libquvi dylib"
    sudo install_name_tool -id @executable_path/../Frameworks/$f $f
  fi
done

# Change liblua's path inside libquvi
echo "Change liblua's path inside libquvi"
sudo install_name_tool -change /usr/local/lib/$LIBLUA @executable_path/../Frameworks/$LIBLUA $LIBQUVI

echo "All done, check to confirm:"
otool -L lib*.dylib
