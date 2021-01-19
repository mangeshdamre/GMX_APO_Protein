# GMX_APO_Protein

Use the following script to generate the GROMACS compatible input files to run the Molecular Dynamics Simulations of any protein (with no LIgand).
## Simulations steps includes:
1] Energy minimization <br>
2] Equilibration <br>
  </t>a) NVT Ensemble <br>
  </t>b) NPT Ensemble <br>
3] Production <br>

## INPUT FILES required for running simulation:
1] ions.mdp # For addition of ions (NA/Cl) in the water box <br>
2] em.mdp   # For Energy minimization <br>
3] nvt.mdp  # For 1st step of equilibration at constant Volume and Temperature <br>
4] npt.mdp  # For 2nd step of equilibration at constant Pressure and Temperature <br>
5] md.mdp   # For Production run <br>

