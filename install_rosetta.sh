#!/bin/bash
# Install Rosetta from GitHub repository
# Note: Rosetta requires academic license for free use
# Commercial use requires paid license

# Don't exit on error for user prompts, but exit on build failures
set +e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "============================================================"
echo "Rosetta Installation from GitHub"
echo "============================================================"
echo ""

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ git not found${NC}"
    echo "Install git first: sudo apt-get install git"
    exit 1
fi

# Check for required build tools
echo -e "${BLUE}Checking build requirements...${NC}"
missing_tools=()

if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
    missing_tools+=("C++ compiler (g++ or clang++)")
fi

if ! command -v python3 &> /dev/null; then
    missing_tools+=("python3")
fi

if [ ${#missing_tools[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠ Missing build tools:${NC}"
    for tool in "${missing_tools[@]}"; do
        echo "   - $tool"
    done
    echo ""
    echo "Install on Ubuntu/Debian:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install build-essential python3 python3-dev"
    echo ""
    read -p "Continue anyway? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Rosetta is already installed and built
if [ -d "rosetta" ]; then
    echo -e "${YELLOW}⚠ Rosetta directory already exists${NC}"
    
    # Check if binaries already exist (check correct Rosetta path)
    ROSETTA_SOURCE="rosetta/source"
    ROSETTA_BIN="rosetta/source/bin"
    
    if [ -d "$ROSETTA_BIN" ] && [ -n "$(ls -A $ROSETTA_BIN 2>/dev/null)" ]; then
        echo -e "${GREEN}✓ Rosetta binaries found in $ROSETTA_BIN${NC}"
        echo ""
        echo "Rosetta appears to be already built!"
        echo "Binaries location: $(pwd)/$ROSETTA_BIN"
        echo ""
        echo "To use Rosetta, add to your PATH:"
        echo "  export PATH=\"\$PATH:$(pwd)/$ROSETTA_BIN\""
        echo ""
        read -p "Rebuild Rosetta anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Keeping existing installation."
            exit 0
        else
            echo "Will rebuild Rosetta..."
        fi
    else
        echo "Rosetta directory exists but binaries not found."
        read -p "Remove directory and reinstall? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing existing rosetta directory..."
            rm -rf rosetta
        else
            echo "Keeping existing directory. Will attempt to build..."
        fi
    fi
fi

# License notice
echo -e "${YELLOW}⚠ IMPORTANT LICENSE NOTICE:${NC}"
echo "Rosetta is free for academic use but requires license agreement."
echo "Commercial use requires a paid license."
echo ""
echo "By proceeding, you agree to Rosetta's license terms:"
echo "  https://www.rosettacommons.org/software/license-and-download"
echo ""
read -p "Do you agree to the license terms? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

# Clone Rosetta repository (skip if already exists)
if [ ! -d "rosetta" ]; then
    echo ""
    echo -e "${BLUE}Cloning Rosetta repository...${NC}"
    echo "This may take several minutes (repository is large)..."
    echo ""

    if git clone --depth 1 https://github.com/RosettaCommons/rosetta.git; then
        echo -e "${GREEN}✓ Rosetta repository cloned${NC}"
    else
        echo -e "${RED}✗ Failed to clone repository${NC}"
        echo "Check your internet connection and try again."
        exit 1
    fi
else
    echo ""
    echo -e "${GREEN}✓ Rosetta repository already exists${NC}"
    echo "Skipping clone step..."
fi

# Navigate to source directory (Rosetta structure: rosetta/source)
if [ ! -d "rosetta/source" ]; then
    echo -e "${RED}✗ rosetta/source directory not found${NC}"
    echo "The Rosetta repository structure may have changed."
    echo "Please check: https://github.com/RosettaCommons/rosetta"
    exit 1
fi

cd rosetta/source

# Check if already built (in current directory, not project bin/)
if [ -d "bin" ] && [ -n "$(ls -A bin 2>/dev/null)" ]; then
    # Verify these are Rosetta binaries, not project binaries
    if [ -f "bin/relax" ] || [ -f "bin/rosetta_scripts" ] || [ -f "bin/docking_protocol" ]; then
        echo ""
        echo -e "${GREEN}✓ Rosetta binaries already exist in bin/ directory${NC}"
        echo ""
        echo "Rosetta appears to be already built!"
        echo "Binaries location: $(pwd)/bin"
        echo ""
        echo "To use Rosetta, add to your PATH:"
        echo "  export PATH=\"\$PATH:$(pwd)/bin\""
        echo ""
        read -p "Rebuild Rosetta anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Keeping existing build."
            exit 0
        else
            echo "Will rebuild Rosetta..."
        fi
    fi
fi

# Check for SCons (should be included in Rosetta repository)
if [ ! -f "scons.py" ]; then
    echo -e "${YELLOW}⚠ scons.py not found in rosetta/main/source${NC}"
    echo "Checking for SCons in parent directories..."
    
    # Check if SCons is in rosetta directory
    if [ -f "../scons.py" ]; then
        echo "Found scons.py in parent directory, creating symlink..."
        ln -sf ../scons.py scons.py
    elif [ -f "../../scons.py" ]; then
        echo "Found scons.py in rosetta directory, creating symlink..."
        ln -sf ../../scons.py scons.py
    else
        echo -e "${YELLOW}⚠ SCons not found in Rosetta repository${NC}"
        echo "Attempting to install SCons via pip..."
        
        # Check if SCons is already installed system-wide
        if python3 -c "import SCons" 2>/dev/null; then
            echo -e "${GREEN}✓ SCons already installed (system-wide)${NC}"
            # Create a wrapper script
            echo '#!/usr/bin/env python3' > scons.py
            echo 'import sys' >> scons.py
            echo 'from SCons.Script import main' >> scons.py
            echo 'if __name__ == "__main__":' >> scons.py
            echo '    sys.exit(main())' >> scons.py
            chmod +x scons.py
        elif command -v pip3 &> /dev/null; then
            echo "Installing SCons via pip..."
            pip3 install scons --quiet
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ SCons installed via pip${NC}"
                # Create a wrapper script
                echo '#!/usr/bin/env python3' > scons.py
                echo 'import sys' >> scons.py
                echo 'from SCons.Script import main' >> scons.py
                echo 'if __name__ == "__main__":' >> scons.py
                echo '    sys.exit(main())' >> scons.py
                chmod +x scons.py
            else
                echo -e "${RED}✗ Failed to install SCons${NC}"
                echo "Please install SCons manually:"
                echo "  pip install scons"
                echo "  Or: conda install -c conda-forge scons"
                exit 1
            fi
        else
            echo -e "${RED}✗ pip3 not found${NC}"
            echo "Please install SCons manually:"
            echo "  pip install scons"
            echo "  Or download from: https://scons.org/"
            exit 1
        fi
    fi
fi

# Verify scons.py is executable
if [ -f "scons.py" ]; then
    chmod +x scons.py
    echo -e "${GREEN}✓ scons.py ready${NC}"
    
    # Test if scons.py works
    if python3 scons.py --version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ SCons is working${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: scons.py may not work correctly${NC}"
    fi
else
    echo -e "${RED}✗ scons.py still not found${NC}"
    exit 1
fi

# Determine number of CPU cores
if command -v nproc &> /dev/null; then
    CORES=$(nproc)
elif command -v sysctl &> /dev/null; then
    CORES=$(sysctl -n hw.ncpu)
else
    CORES=4  # Default
fi

echo ""
echo -e "${BLUE}Building Rosetta...${NC}"
echo "This will take 30-120 minutes depending on your system"
echo "Using $CORES CPU cores"
echo ""
echo "You can monitor progress in another terminal."
echo ""

# Build Rosetta
# Note: This builds in release mode which is faster but larger
# For development, use: mode=debug
BUILD_JOBS=${CORES}
echo "Running: ./scons.py -j${BUILD_JOBS} mode=release bin"
echo ""

# Enable exit on error for build
set -e

if ./scons.py -j${BUILD_JOBS} mode=release bin; then
    echo ""
    echo -e "${GREEN}✓ Rosetta built successfully!${NC}"
    echo ""
    echo "============================================================"
    echo "Installation Complete"
    echo "============================================================"
    echo ""
    ROSETTA_BIN_PATH="$(pwd)/bin"
    echo "Rosetta binaries are located at:"
    echo "  $ROSETTA_BIN_PATH"
    echo ""
    echo "To use Rosetta, add to your PATH:"
    echo "  export PATH=\"\$PATH:$ROSETTA_BIN_PATH\""
    echo ""
    echo "Or add to your ~/.bashrc or ~/.zshrc:"
    echo "  echo 'export PATH=\"\$PATH:$ROSETTA_BIN_PATH\"' >> ~/.bashrc"
    echo ""
    echo "Common Rosetta applications:"
    echo "  - relax: Structure relaxation"
    echo "  - rosetta_scripts: General purpose scripting"
    echo "  - docking_protocol: Protein-protein docking"
    echo ""
else
    echo ""
    echo -e "${RED}✗ Rosetta build failed${NC}"
    echo ""
    echo "Common issues:"
    echo "1. Missing dependencies - install build-essential"
    echo "2. Insufficient memory - try with fewer cores: -j2"
    echo "3. Check Rosetta documentation for troubleshooting"
    echo ""
    echo "Documentation: https://www.rosettacommons.org/docs"
    exit 1
fi

