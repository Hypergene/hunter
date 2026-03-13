#!/bin/bash
set -e

verbose=false
install_deps=false
build_docs=true

function print_synopsis {
  echo "$0 [options] "
  echo "    -h, --help         print this help message and exit."
  echo "    -v, --verbose      print each executed command."
  echo "    -i, --install-deps install dependencies before building."
  echo "    --skip-build       skip building and spellchecking docs."
  echo "                       Useful to just install dependencies."
}

function wrong_dir() {
  echo "Please run script from 'docs' directory"
  exit 1
}

# https://stackoverflow.com/a/14203146
# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -h|--help)
    print_synopsis
    exit 0
  ;;
  -v|--verbose)
    verbose=true
  ;;
  -i|--install-deps)
    install_deps=true
  ;;
  --skip-build)
    build_docs=false
  ;;
  -*)
    # unknown option
    echo "error: unknown option '$key'"
    echo ""
    print_synopsis
    exit 1
  ;;
  *)
    # no free arguments allowed
    echo "error: no free arguments allowed: '$key'"
    echo ""
    print_synopsis
    exit 1
  ;;
esac
shift # past argument or value
done

if [ "$verbose" = true ]; then
  set -x
fi

if [ "$install_deps" = true ]; then
  echo "### Update apt cache ###"
  sudo apt-get update -qq
  echo "### install sphinx packages ###"
  echo "  - pyhton3-sphinx           - base package"
  echo "  - python3-sphinx-rtd-theme - nice read-the-docs theme"
  echo "  - python3-sphinxcontrib.spelling - spellcheck sphinx files"
  #echo "  - texlive-latex-extra      - latex support to render pdf and also math in html"
  #echo "  - dvipng                   - convert math formulas to pngs for html output"
  #echo "  - graphviz                 - support for dot, creating flowcharts and other graphs"
  echo "  - python3-matplotlib       - support for matplotlib plots"
  echo "  - python3-myst-parser      - support for markdown files"
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install --no-install-recommends \
    python3-sphinx python3-sphinx-rtd-theme python3-sphinxcontrib.spelling python3-matplotlib python3-myst-parser
fi

# determine build and install directory
SCRIPT_DIR=$(dirname "$0")
SCRIPT_DIR_ABS=$(realpath "${SCRIPT_DIR}")

if [ "$build_docs" = true ]; then
  cd "${SCRIPT_DIR_ABS}"
  echo "### remove old build directories ###"
  rm -rf _build _static _spelling
  echo "### create _static dir ###"
  mkdir _static

  echo "### run sphinx-build ###"
  sphinx-build -v -W . _build
  echo "### run sphinx spell checking ###"
  sphinx-build -b spelling . _spelling
  echo "### done! ###"
fi
