# GMX_APO_Protein

Use the script (**<a href="https://github.com/mangeshdamre/GMX_APO_Protein/blob/main/gmx_input.sh" target="_blank">gmx_input.sh</a>**) to generate the GROMACS compatible input files to run the Molecular Dynamics Simulations of any protein (with no LIgand).

## System Requirements
- GROMACS # How to install GROMACS? <a href="https://manual.gromacs.org/documentation/current/install-guide/index.html" target="_blank">GROMACS INSTALLATION</a><br>
- XMGRACE # How to install XMGRACE? <a href="https://github.com/ma-laforge/HowTo/blob/master/grace/grace_install.md" target="_blank">XMGRACE INSTALLATION</a><br>
- GNUPLOT # How to install GNUPLOT? <a href="http://www.gnuplot.info/" target="_blank">GNUPLOT INSTALLATION</a><br>
- DSSP # How to install DSSP? <a href="http://biskit.pasteur.fr/install/applications/dssp" target="_blank">DSSP INSTALLATION</a><br>

## Simulations steps:
- **Energy minimization** <br>
- **Equilibration** <br>
  - **NVT Ensemble** <br>
  - **NPT Ensemble** <br>
- **Production** <br>

## INPUT FILES required for running simulation:
- **<a href="https://github.com/mangeshdamre/GMX_APO_Protein/blob/main/mdp/ions.mdp" target="_blank">ions.mdp</a>** # For addition of ions (Na/Cl) in the water box <br>
- **<a href="https://github.com/mangeshdamre/GMX_APO_Protein/blob/main/mdp/em.mdp" target="_blank">em.mdp</a>**   # For Energy minimization <br>
- **<a href="https://github.com/mangeshdamre/GMX_APO_Protein/blob/main/mdp/nvt.mdp" target="_blank">nvt.mdp</a>**  # For 1st step of equilibration at constant Volume and Temperature <br>
- **<a href="https://github.com/mangeshdamre/GMX_APO_Protein/blob/main/mdp/npt.mdp" target="_blank">npt.mdp</a>**  # For 2nd step of equilibration at constant Pressure and Temperature <br>
- **<a href="https://github.com/mangeshdamre/GMX_APO_Protein/blob/main/mdp/md.mdp" target="_blank">md.mdp</a>**   # For Production run <br>

