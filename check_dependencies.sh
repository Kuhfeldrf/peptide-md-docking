#!/bin/bash
# Dependency check script
# Run this to verify all dependencies are installed

echo "============================================================"
echo "Dependency Check"
echo "============================================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check Python virtual environment
if [ -d ".venv" ]; then
    echo -e "${GREEN}✓ Virtual environment (.venv) exists${NC}"
else
    echo -e "${RED}✗ Virtual environment not found${NC}"
    echo "  Run: ./install_dependencies.sh"
    exit 1
fi

# Activate venv and check Python packages
source .venv/bin/activate

echo ""
echo "Python Packages:"
echo "----------------"

packages=("Bio" "numpy" "rdkit" "pymatgen" "requests")
missing_packages=()

for pkg in "${packages[@]}"; do
    if python3 -c "import $pkg" 2>/dev/null; then
        echo -e "${GREEN}✓ $pkg${NC}"
    else
        echo -e "${RED}✗ $pkg${NC}"
        missing_packages+=("$pkg")
    fi
done

# Check OpenBabel
if python3 -c "from openbabel import openbabel" 2>/dev/null; then
    echo -e "${GREEN}✓ openbabel (Python)${NC}"
else
    echo -e "${YELLOW}⚠ openbabel (Python)${NC}"
fi

if command -v obabel &> /dev/null; then
    echo -e "${GREEN}✓ obabel (CLI)${NC}"
else
    echo -e "${YELLOW}⚠ obabel (CLI) not in PATH${NC}"
fi

echo ""
echo "External Tools:"
echo "---------------"

# Check AutoDock Vina
vina_found=false
if command -v vina &> /dev/null || command -v vina.exe &> /dev/null; then
    echo -e "${GREEN}✓ AutoDock Vina${NC}"
    vina_found=true
else
    # Check in project bin directory
    if [ -f "bin/vina" ] || [ -f ".venv/bin/vina" ]; then
        echo -e "${GREEN}✓ AutoDock Vina (local)${NC}"
        vina_found=true
    else
        echo -e "${RED}✗ AutoDock Vina${NC}"
        echo "    Install: https://vina.scripps.edu/downloads/"
        echo "    Or see: INSTALL_MANUAL.md"
    fi
fi

# Check Rosetta (multiple locations)
rosetta_found=false
rosetta_location=""

# Check system PATH
if command -v rosetta_scripts &> /dev/null; then
    echo -e "${GREEN}✓ Rosetta (rosetta_scripts)${NC}"
    rosetta_found=true
    rosetta_location="PATH"
fi
if command -v relax &> /dev/null; then
    echo -e "${GREEN}✓ Rosetta (relax)${NC}"
    rosetta_found=true
    if [ -z "$rosetta_location" ]; then
        rosetta_location="PATH"
    fi
fi

# Check local rosetta installation (from install_rosetta.sh)
# Rosetta structure: rosetta/source/bin (binaries built here)
if [ -d "rosetta" ] && [ -d "rosetta/source" ]; then
    # Check if binaries exist in rosetta/source/bin
    if [ -d "rosetta/source/bin" ]; then
        # Verify these are actual Rosetta binaries, not just any files
        # Rosetta binaries have .linuxgccrelease extension (or other platform-specific extensions)
        if [ -f "rosetta/source/bin/relax" ] || [ -f "rosetta/source/bin/rosetta_scripts" ] || \
           [ -f "rosetta/source/bin/docking_protocol" ] || [ -f "rosetta/source/bin/fixbb" ] || \
           [ -f "rosetta/source/bin/relax.linuxgccrelease" ] || [ -f "rosetta/source/bin/rosetta_scripts.linuxgccrelease" ] || \
           [ -f "rosetta/source/bin/docking_protocol.linuxgccrelease" ] || [ -f "rosetta/source/bin/fixbb.linuxgccrelease" ] || \
           [ "$(ls rosetta/source/bin/*.linuxgccrelease 2>/dev/null | wc -l)" -gt 0 ]; then
            if [ "$rosetta_found" = false ]; then
                echo -e "${GREEN}✓ Rosetta (local: rosetta/source/bin)${NC}"
                rosetta_found=true
                rosetta_location="local"
            fi
        fi
    elif [ -d "rosetta/source" ]; then
        # Rosetta source exists but not built yet
        if [ "$rosetta_found" = false ]; then
            echo -e "${YELLOW}⚠ Rosetta source found but not built${NC}"
            echo "    Build with: ./install_rosetta.sh"
        fi
    fi
fi

if [ "$rosetta_found" = false ]; then
    echo -e "${YELLOW}⚠ Rosetta (optional)${NC}"
    echo "    Install: ./install_rosetta.sh (from GitHub)"
    echo "    Or: conda install -c conda-forge rosetta"
    echo "    Or see: INSTALL_MANUAL.md"
    echo "    Note: AutoDock Vina works well for basic docking"
fi

# Check MGLTools
if [ -f "prepare_receptor4.py" ]; then
    echo -e "${GREEN}✓ MGLTools (prepare_receptor4.py)${NC}"
else
    echo -e "${YELLOW}⚠ MGLTools${NC}"
    echo "    Download: https://ccsb.scripps.edu/mgltools/downloads/"
fi

# Check xtb-python (OPTIONAL)
if python3 -c "import xtb" 2>/dev/null; then
    echo -e "${GREEN}✓ xtb-python${NC}"
else
    echo -e "${YELLOW}⚠ xtb-python (OPTIONAL)${NC}"
    echo "    Only needed for quantum chemistry calculations"
    echo "    Install: conda install -c conda-forge xtb-python"
    echo "    Note: Docking workflow works without it"
fi

echo ""
echo "============================================================"
if [ ${#missing_packages[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All core dependencies are installed!${NC}"
else
    echo -e "${YELLOW}⚠ Some dependencies are missing${NC}"
    echo "  Run: ./install_dependencies.sh"
fi
echo "============================================================"

