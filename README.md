# GMX_APO_Protein

Use the following script to generate the GROMACS compatible input files to run the Molecular Dynamics Simulations of any protein (with no LIgand).
## Simulations steps includes:
1] Energy minimization
2] Equilibration
  a) NVT Ensemble
  b) NPT Ensemble
3] Production

## INPUT FILES required for running simulation:
1] ions.mdp # For addition of ions (NA/Cl) in the water box
2] em.mdp   # For Energy minimization
3] nvt.mdp  # For 1st step of equilibration at constant Volume and Temperature
4] npt.mdp  # For 2nd step of equilibration at constant Pressure and Temperature
5] md.mdp   # For Production run

