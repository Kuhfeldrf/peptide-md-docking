#!/bin/bash
# Installation script for peptide-protein docking dependencies
# Run this script to install all required dependencies

set -e  # Exit on error

echo "============================================================"
echo "Peptide-Protein Docking Dependencies Installation"
echo "============================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    python3 -m venv .venv
fi

# Activate virtual environment
echo -e "${GREEN}Activating virtual environment...${NC}"
source .venv/bin/activate

# Upgrade pip
echo -e "${GREEN}Upgrading pip...${NC}"
pip install --upgrade pip --quiet

# Install Python packages from requirements.txt
echo -e "${GREEN}Installing Python packages from requirements.txt...${NC}"
pip install -r requirements.txt

# Check for conda
if command -v conda &> /dev/null; then
    echo ""
    echo -e "${YELLOW}Checking for optional dependencies via conda...${NC}"
    
    # Check for Rosetta
    if ! conda list -n base rosetta 2>/dev/null | grep -q rosetta; then
        echo -e "${YELLOW}Rosetta not found. Install with:${NC}"
        echo "  conda install -c conda-forge rosetta"
        echo "  (Academic use is free, commercial requires license)"
    else
        echo -e "${GREEN}✓ Rosetta found${NC}"
    fi
    
    # Check for xtb-python
    if ! conda list -n base xtb-python 2>/dev/null | grep -q xtb-python; then
        echo -e "${YELLOW}xtb-python not found. Install with:${NC}"
        echo "  conda install -c conda-forge xtb-python"
    else
        echo -e "${GREEN}✓ xtb-python found${NC}"
    fi
else
    echo -e "${YELLOW}Conda not found. Install conda for optional dependencies:${NC}"
    echo "  - Rosetta: conda install -c conda-forge rosetta"
    echo "  - xtb-python: conda install -c conda-forge xtb-python"
fi

# Check for AutoDock Vina
echo ""
echo -e "${YELLOW}Checking for AutoDock Vina...${NC}"
if command -v vina &> /dev/null || command -v vina.exe &> /dev/null; then
    echo -e "${GREEN}✓ AutoDock Vina found${NC}"
else
    echo -e "${YELLOW}AutoDock Vina not found. Install from:${NC}"
    echo "  https://vina.scripps.edu/downloads/"
    echo "  Or: conda install -c conda-forge autodock-vina"
fi

# Check for OpenBabel
echo ""
echo -e "${YELLOW}Checking for OpenBabel...${NC}"
if command -v obabel &> /dev/null; then
    echo -e "${GREEN}✓ OpenBabel found${NC}"
else
    echo -e "${YELLOW}OpenBabel command-line tool not found${NC}"
    echo "  (Python package is installed, but CLI tool may be missing)"
    echo "  Install with: conda install -c conda-forge openbabel"
fi

# Check for MGLTools
echo ""
echo -e "${YELLOW}Checking for MGLTools...${NC}"
if [ -f "prepare_receptor4.py" ]; then
    echo -e "${GREEN}✓ prepare_receptor4.py found${NC}"
else
    echo -e "${YELLOW}MGLTools not found. Download from:${NC}"
    echo "  https://ccsb.scripps.edu/mgltools/downloads/"
fi

echo ""
echo "============================================================"
echo -e "${GREEN}Installation Summary${NC}"
echo "============================================================"
echo ""
echo "Core dependencies installed in virtual environment:"
echo "  ✓ biopython"
echo "  ✓ numpy"
echo "  ✓ rdkit-pypi"
echo "  ✓ pymatgen"
echo "  ✓ openbabel-wheel"
echo "  ✓ requests"
echo ""
echo "Optional dependencies (install separately if needed):"
echo "  - Rosetta: conda install -c conda-forge rosetta"
echo "  - AutoDock Vina: https://vina.scripps.edu/downloads/"
echo "  - MGLTools: https://ccsb.scripps.edu/mgltools/downloads/"
echo "  - xtb-python: conda install -c conda-forge xtb-python"
echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "To activate the environment:"
echo "  source .venv/bin/activate"
echo ""
echo "To check dependencies:"
echo "  ./check_dependencies.sh"

