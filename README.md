# Peptide-Protein Docking with AlphaFold & Rosetta

A streamlined workflow for predicting peptide 3D structures using AlphaFold and performing advanced peptide-protein docking using Rosetta.

## Overview

This repository provides a complete workflow for:
1. **Peptide Structure Prediction** - Using AlphaFold/ESMFold to predict 3D structures from amino acid sequences
2. **Structure Relaxation** - Using Rosetta to refine and optimize structures
3. **Peptide-Protein Docking** - Using Rosetta for advanced docking simulations

## Quick Start

### 1. Install Dependencies

```bash
# Make scripts executable
chmod +x install_dependencies.sh install_rosetta.sh check_dependencies.sh

# Install Python dependencies
./install_dependencies.sh

# Install Rosetta (required for docking workflow)
./install_rosetta.sh
```

### 2. Verify Installation

```bash
# Check all dependencies
./check_dependencies.sh
```

### 3. Run the Workflow

```bash
# Activate virtual environment
source .venv/bin/activate

# Start Jupyter Notebook
jupyter notebook
```

Open one of the workflow notebooks:
- `peptide_structure_predictor.ipynb` - Complete workflow for peptide prediction and docking
- `predict_peptide_structure_and_dock_local.ipynb` - Local execution workflow
- `ligand-protein test with hpc offloading.ipynb` - HPC cluster offloading workflow

### Which Notebook Should I Use?

- **For most users**: Start with `peptide_structure_predictor.ipynb` - it contains the complete workflow
- **For local-only execution**: Use `predict_peptide_structure_and_dock_local.ipynb` if you want to run everything locally
- **For HPC clusters**: Use `ligand-protein test with hpc offloading.ipynb` if you have access to an HPC cluster and want to offload Rosetta jobs

## Workflow

### Step 1: Predict Peptide Structure

```python
# Predict structure from sequence
predicted_pdb = predict_peptide_structure_alphafold(
    "ACDEFGHIKLMNPQRSTVWY", 
    method="colabfold_api"
)
```

### Step 2: Relax Receptor Structure

```python
# Relax receptor structure (recommended before docking)
relaxed = rosetta_relax('3fxi.pdb', nstruct=1)
```

### Step 3: Dock Peptide to Receptor

```python
# Dock peptide to relaxed receptor
docked = rosetta_peptide_docking(
    relaxed, 
    'ACDEFGHIKLMNPQRSTVWY_alphafold.pdb', 
    nstruct=1  # Start with 1 for testing, use 5-10 for production
)
```

## Dependencies

### Core (Installed Automatically)
- **biopython** - Protein structure handling
- **numpy** - Numerical computations
- **rdkit-pypi** - Molecular modeling
- **pymatgen** - Materials science toolkit
- **openbabel-wheel** - Structure format conversion
- **requests** - API calls for AlphaFold

### Required External Tools

#### Rosetta Suite
**Installation:**
```bash
./install_rosetta.sh
```

This will:
- Clone Rosetta from GitHub
- Build binaries (takes 30-120 minutes)
- Set up binaries in `rosetta/source/bin/`

**Note:** Rosetta is free for academic use. Commercial use requires a license.

## Notebooks

This repository contains three main notebooks for peptide structure prediction and docking:

1. **`peptide_structure_predictor.ipynb`** - Complete workflow notebook containing:
   - Peptide structure prediction using AlphaFold/ESMFold (via API)
   - Rosetta structure relaxation
   - Rosetta peptide-protein docking
   - Batch processing capabilities

2. **`predict_peptide_structure_and_dock_local.ipynb`** - Local execution workflow with:
   - Peptide structure prediction (AlphaFold/ESMFold)
   - Local Rosetta docking and relaxation
   - All functions optimized for local machine execution

3. **`ligand-protein test with hpc offloading.ipynb`** - HPC cluster workflow featuring:
   - Peptide structure prediction
   - HPC offloading functions for Rosetta jobs
   - File transfer utilities for cluster submission
   - Remote job execution and monitoring

## File Structure

```
peptide-md-docking/
├── peptide_structure_predictor.ipynb          # Complete workflow notebook
├── predict_peptide_structure_and_dock_local.ipynb  # Local execution workflow
├── ligand-protein test with hpc offloading.ipynb   # HPC cluster workflow
├── install_dependencies.sh                    # Install Python dependencies
├── install_rosetta.sh                        # Install Rosetta suite
├── check_dependencies.sh                     # Verify installation
├── requirements.txt                          # Python package list
├── 3fxi.pdb                                 # Example receptor structure
├── intestinal unique peptides.txt           # Example peptide sequences
├── alphafold_predictions/                   # Predicted peptide structures
├── rosetta/                                 # Rosetta installation
├── rosetta_docking/                         # Rosetta docking outputs
└── archive/                                 # Archived/unused files
```

## Usage Examples

### Batch Peptide Prediction

```python
# Extract peptides from file
peptides = extract_peptides_from_fasta(
    "intestinal unique peptides.txt", 
    num_peptides=5
)

# Predict structures
for seq in peptides:
    predicted = predict_peptide_structure_alphafold(seq)
```

### Full Docking Workflow

```python
# 1. Relax receptor
relaxed = rosetta_relax('3fxi.pdb', nstruct=5)

# 2. Dock peptide
docked = rosetta_peptide_docking(
    relaxed, 
    'peptide_alphafold.pdb', 
    nstruct=10
)
```

## Performance Notes

- **Peptide Prediction**: ~10-30 seconds per peptide (via API)
- **Structure Relaxation**: ~15-45 minutes per structure (depends on size)
- **Peptide Docking**: ~1-2 hours per structure (depends on complexity)

For large complexes, consider:
- Starting with `nstruct=1` for testing
- Running `nstruct=5-10` overnight for production
- Using faster machines or clusters for large-scale runs

## Troubleshooting

### Rosetta Not Found
```bash
# Re-run installation
./install_rosetta.sh

# Or check manually
./check_dependencies.sh
```

### Dependencies Missing
```bash
# Reinstall Python packages
source .venv/bin/activate
pip install -r requirements.txt
```

### Build Issues
- Ensure you have build tools: `sudo apt-get install build-essential`
- Check available memory (Rosetta build requires ~4GB RAM)
- Try building with fewer cores: Edit `install_rosetta.sh` and change `-j${CORES}` to `-j2`

## License

This workflow uses:
- **Rosetta**: Free for academic use, commercial requires license
- **AlphaFold/ESMFold**: Open source
- **Other tools**: Various open-source licenses (BSD, GPL, Apache)

## Citation

If you use this workflow, please cite:
- Rosetta: [Rosetta Commons](https://www.rosettacommons.org/)
- AlphaFold: [AlphaFold Paper](https://www.nature.com/articles/s41586-021-03819-2)
- ESMFold: [ESMFold Paper](https://www.biorxiv.org/content/10.1101/2022.07.20.500902v1)
