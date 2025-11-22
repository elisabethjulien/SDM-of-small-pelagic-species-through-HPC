#!/bin/bash
#SBATCH --job-name=Rfilter
#SBATCH --account=f202415137cpcaa0a
#SBATCH --partition=normal-arm
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=28G
#SBATCH --output=Rfilter.out
#SBATCH --error=Rfilter.err
#SBATCH -D /projects/F202415137CPCAA0

module purge
module load foss/2024a
module load R/4.4.2-gfbf-2024a

module load GDAL/3.10.0-foss-2024a
module load PROJ/9.5.1-GCCcore-13.3.0
module load GEOS/3.12.2-GCC-13.3.0
module load UDUNITS/2.2.28-GCCcore-13.3.0
module load SQLite/3.45.3-GCCcore-13.3.0
module load CMake/3.29.3-GCCcore-13.3.0

export R_LIBS="~/R/arm-4.4"

echo "Starting R job at: $(date)"
Rscript /projects/F202415137CPCAA0/small_pel_geofiltering/Rfilter.r
echo "Finished R job at: $(date)"
