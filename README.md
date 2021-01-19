# GMX_APO_Protein

Use the following script to generate the GROMACS compatible input files to run the Molecular Dynamics Simulations of any protein (with no LIgand).

## System Requirements
- GROMACS
- XMGRACE
- GNUPLOT

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

