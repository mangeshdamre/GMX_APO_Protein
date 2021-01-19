#!/bin/bash

pdb=<protein name without extension>

#Prepare the Topology
    echo 14 | gmx_mpi_d pdb2gmx -f $pdb.pdb -o $pdb-processed.gro -water spce

#Define the unit box
    gmx_mpi_d editconf -f $pdb-processed.gro -o $pdb-newbox.gro -c -d 1.3 -bt cubic

#Adding Solvent
    gmx_mpi_d solvate -cp $pdb-newbox.gro -cs spc216.gro -o $pdb-solv.gro -p topol.top

#Adding Ions
    gmx_mpi_d grompp -f ions.mdp -c $pdb-solv.gro -p topol.top -o ions-$pdb.tpr
        echo 13 | gmx_mpi_d genion -s ions-$pdb.tpr -o $pdb-solv-ions.gro -p topol.top -pname NA -nname CL -neutral

#Energy Minimization
    gmx_mpi_d grompp -f minim.mdp -c $pdb-solv-ions.gro -p topol.top -o em-$pdb.tpr
       mpirun -np 64 gmx_mpi_d mdrun -v -deffnm em-$pdb

#Calculate Potential
    echo 10 0 | gmx_mpi_d energy -f em-$pdb.edr -o potential-em-$pdb.xvg

#Create potential.png
    grace -nxy potential-em-$pdb.xvg -hdevice PNG -hardcopy -printfile potential-em-$pdb.png

#Equilibration at constant temperature
    gmx_mpi_d grompp -f nvt.mdp -c em-$pdb.gro -r em-$pdb.gro -p topol.top -o nvt-$pdb.tpr
        mpirun -np 64 gmx_mpi_d mdrun -deffnm nvt-$pdb -v

#Calculate Temperature
    echo 16 | gmx_mpi_d energy -f nvt-$pdb.edr -o temperature-em-$pdb.xvg

#Create temperature.png
    grace -nxy temperature-em-$pdb.xvg -hdevice PNG -hardcopy -printfile temperature-em-$pdb.png

#Equilibration at constant pressure
    gmx_mpi_d grompp -f npt.mdp -c nvt-$pdb.gro -r nvt-$pdb.gro -t nvt-$pdb.cpt -p topol.top -o npt-$pdb.tpr
        mpirun -np 64 gmx_mpi_d mdrun -deffnm npt-$pdb -v

#Calculate Pressure
    echo 18 | gmx_mpi_d energy -f npt-$pdb.edr -o pressure-npt-$pdb.xvg

    ##Create pressure.png
        grace -nxy pressure-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile pressure-npt-$pdb.png

#Calculate Density-NPT
    echo 24 | gmx_mpi_d energy -f npt-$pdb.edr -o density-npt-$pdb.xvg

    ##Create density-npt.png
        grace -nxy density-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile density-npt-$pdb.png

#Calculate rmsd-npt
    echo 4 4 | gmx_mpi_d rms -f npt-$pdb.xtc -s npt-$pdb.tpr -o rmsd-npt-$pdb.xvg -tu ns

    ##Create rmsd-npt.png
        grace -nxy rmsd-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile rmsd-npt-$pdb.png

#Calculate rmsf-npt
    echo 4 | gmx_mpi_d rmsf -f npt-$pdb.xtc -s npt-$pdb.tpr -o rmsf-npt-$pdb.xvg -res

    ##Create rmsf-npt.png
        grace -nxy rmsf-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile rmsf-npt-$pdb.png

#Calculate Hbond
    ## Select 1 for acceptor and 1 for donor
        echo 1 1 | gmx_mpi_d hbond -f npt-$pdb.xtc -s npt-$pdb.tpr -num Hbond-npt-$pdb.xvg

    ##Create Hbond-npt.png
        grace -nxy Hbond-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile Hbond-npt-$pdb.png

#MD Production
    gmx_mpi_d grompp -f md.mdp -c npt-$pdb.gro -t npt-$pdb.cpt -p topol.top -o md-$pdb.tpr
        mpirun -np 64 gmx_mpi_d mdrun -deffnm md-$pdb -v
#Else to use gpu
# gmx_mpi_d mdrun -deffnm md-$pdb -nb gpu

#Analysis
    ## Periodicty correction
        ### select 1 for protein and 0 for system
            echo 1 0 | gmx_mpi_d trjconv -s md-$pdb.tpr -f md-$pdb.xtc -o md-$pdb-noPBC.xtc -pbc mol -center

    ## RMSD calculation : Protein backbone
        ### select 4 for protein backbone
            echo 4 4 | gmx_mpi_d rms -s md-$pdb.tpr -f md-$pdb-noPBC.xtc -o rmsd-md-$pdb.xvg -tu ns

    ## RMSF calculation : Protein backbone
        ### select 4 for protein backbone
            echo 4 | gmx_mpi_d rmsf -s md-$pdb.tpr -f md-$pdb-noPBC.xtc -o rmsf-md-$pdb.xvg -res
            ####Create rmsf-md-$pdb.png
                grace -nxy rmsf-md-$pdb.xvg -hdevice PNG -hardcopy -printfile rmsf-md-$pdb.png

    ## RMSF calculation 1ns: Protein backbone
        ### select 4 for protein backbone
            echo 4 | gmx_mpi_d rmsf -s md-$pdb.tpr -f md-$pdb-noPBC.xtc -o rmsf-md-$pdb-1ns.xvg -res -b 0 -e 1000
            ####Create rmsf-md-$pdb-1ns.png
                grace -nxy rmsf-md-$pdb-1ns.xvg -hdevice PNG -hardcopy -printfile rmsf-md-$pdb-1ns.png

    ## RMSD calculation relative to crystal/initial structure: Protein backbone
        ### select 4 for protein backbone
            echo 4 4 | gmx_mpi_d rms -s em-$pdb.tpr -f md-$pdb-noPBC.xtc -o rmsd-xtal-$pdb.xvg -tu ns
            #### Create rmsd.png from MD production
        grace -block rmsd-md-$pdb.xvg -bxy 1:2 -block rmsd-xtal-$pdb.xvg -bxy 1:2 -hdevice PNG -hardcopy -printfile rmsd-MD-$pdb.png

    ## Radius of Gyration
        ### select 1 for protein
            echo 1 | gmx_mpi_d gyrate -s md-$pdb.tpr -f md-$pdb-noPBC.xtc -o gyrate-md-$pdb.xvg
            ####Create gyrate.png from MD production
                grace -nxy gyrate-md-$pdb.xvg -hdevice PNG -hardcopy -printfile gyrate-md-$pdb.png

    ##Calculate Hbond
        ### Select 1 for acceptor and 1 for donor
            echo 1 1 | gmx_mpi_d hbond -f md-$pdb-noPBC.xtc -s md-$pdb.tpr -num Hbond-md-$pdb.xvg
            ####Create Hbond-npt.png
                grace -nxy Hbond-md-$pdb.xvg -hdevice PNG -hardcopy -printfile Hbond-md-$pdb.png

    ##Calculate DSSP
        export DSSP=/usr/bin/dssp
        echo 1 | gmx_mpi_d do_dssp -f md-$pdb-noPBC.xtc -s md-$pdb.tpr -o dssp-md-$pdb.xpm
    ##Calculate SASA
	echo 1 | gmx_mpi_d sasa -f md-$pdb-noPBC.xtc -s md-$pdb.tpr -o sasa-md-$pdb.xvg -tu ns
