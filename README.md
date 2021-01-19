# GMX_APO_Protein

Use the following script to generate the GROMACS compatible input files to run the Molecular Dynamics Simulations of any protein (with no LIgand).

## System Requirements
- GROMACS # How to install GROMACS? <a href="https://manual.gromacs.org/documentation/current/install-guide/index.html" target="_blank">GROMACS INSTALLATION</a><br>
- XMGRACE # How to install XMGRACE? <a href="https://github.com/ma-laforge/HowTo/blob/master/grace/grace_install.md" target="_blank">XMGRACE INSTALLATION</a><br>
- GNUPLOT # How to install XMGRACE? <a href="http://www.gnuplot.info/" target="_blank">GNUPLOT INSTALLATION</a><br>

## Simulations steps includes:
- **Energy minimization** <br>
- **Equilibration** <br>
  - **NVT Ensemble** <br>
  - **NPT Ensemble** <br>
- **Production** <br>

## INPUT FILES required for running simulation:
- **ions.mdp** # For addition of ions (Na/Cl) in the water box <br>
- **em.mdp**   # For Energy minimization <br>
- **nvt.mdp**  # For 1st step of equilibration at constant Volume and Temperature <br>
- **npt.mdp**  # For 2nd step of equilibration at constant Pressure and Temperature <br>
- **md.mdp**   # For Production run <br>

