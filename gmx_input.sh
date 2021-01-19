#!/bin/bash

pdb= <protein name without extension>
exe=gmx # Replace gmx as per the system availability
#Prepare the Topology
    echo 14 | $exe pdb2gmx -f $pdb.pdb -o $pdb-processed.gro -water spce
    # If there are missing atoms in the pdb then use the following command
    # echo 14 | $exe pdb2gmx -f $pdb.pdb -o $pdb-processed.gro -water spce -missing
:"
Select the Force Field:
From '/usr/local/gromacs2019/share/gromacs/top':
 1: AMBER03 protein, nucleic AMBER94 (Duan et al., J. Comp. Chem. 24, 1999-2012, 2003)
 2: AMBER94 force field (Cornell et al., JACS 117, 5179-5197, 1995)
 3: AMBER96 protein, nucleic AMBER94 (Kollman et al., Acc. Chem. Res. 29, 461-469, 1996)
 4: AMBER99 protein, nucleic AMBER94 (Wang et al., J. Comp. Chem. 21, 1049-1074, 2000)
 5: AMBER99SB protein, nucleic AMBER94 (Hornak et al., Proteins 65, 712-725, 2006)
 6: AMBER99SB-ILDN protein, nucleic AMBER94 (Lindorff-Larsen et al., Proteins 78, 1950-58, 2010)
 7: AMBERGS force field (Garcia & Sanbonmatsu, PNAS 99, 2782-2787, 2002)
 8: CHARMM27 all-atom force field (CHARM22 plus CMAP for proteins)
 9: GROMOS96 43a1 force field
10: GROMOS96 43a2 force field (improved alkane dihedrals)
11: GROMOS96 45a3 force field (Schuler JCC 2001 22 1205)
12: GROMOS96 53a5 force field (JCC 2004 vol 25 pag 1656)
13: GROMOS96 53a6 force field (JCC 2004 vol 25 pag 1656)
14: GROMOS96 54a7 force field (Eur. Biophys. J. (2011), 40,, 843-856, DOI: 10.1007/s00249-011-0700-9)
15: GROMOS96 54a7 force field (Eur. Biophys. J. (2011), 40,, 843-856, DOI: 10.1007/s00249-011-0700-9)
16: OPLS-AA/L all-atom force field (2001 aminoacid dihedrals)
"
#Define the unit box
    $exe editconf -f $pdb-processed.gro -o $pdb-newbox.gro -c -d 1.2 -bt cubic

#Adding Solvent
    $exe solvate -cp $pdb-newbox.gro -cs spc216.gro -o $pdb-solv.gro -p topol.top

#Adding Ions
    $exe grompp -f ions.mdp -c $pdb-solv.gro -p topol.top -o ions-$pdb.tpr
        echo 13 | $exe genion -s ions-$pdb.tpr -o $pdb-solv-ions.gro -p topol.top -pname NA -nname CL -neutral
:"
Select a continuous group of solvent molecules
Group     0 (         System) has 71958 elements
Group     1 (        Protein) has  2790 elements
Group     2 (      Protein-H) has  2196 elements
Group     3 (        C-alpha) has   279 elements
Group     4 (       Backbone) has   837 elements
Group     5 (      MainChain) has  1118 elements
Group     6 (   MainChain+Cb) has  1386 elements
Group     7 (    MainChain+H) has  1392 elements
Group     8 (      SideChain) has  1398 elements
Group     9 (    SideChain-H) has  1078 elements
Group    10 (    Prot-Masses) has  2790 elements
Group    11 (    non-Protein) has 69168 elements
Group    12 (          Water) has 69168 elements
Group    13 (            SOL) has 69168 elements
Group    14 (      non-Water) has  2790 elements
"
#Energy Minimization
    $exe grompp -f em.mdp -c $pdb-solv-ions.gro -p topol.top -o em-$pdb.tpr
       $exe mdrun -v -deffnm em-$pdb
       # mpirun -np 64 gmx_mpi_d mdrun -v -deffnm em-$pdb # to run in parallel

#Calculate Potential
    echo 10 0 | $exe energy -f em-$pdb.edr -o potential-em-$pdb.xvg
:"
Select the terms you want from the following list by
selecting either (part of) the name or the number or a combination.
End your selection with an empty line or a zero.
-------------------------------------------------------------------
  1  G96Bond          2  G96Angle         3  Proper-Dih.      4  Improper-Dih. 
  5  LJ-14            6  Coulomb-14       7  LJ-(SR)          8  Coulomb-(SR)  
  9  Coul.-recip.    10  Potential       11  Pressure        12  Vir-XX        
 13  Vir-XY          14  Vir-XZ          15  Vir-YX          16  Vir-YY        
 17  Vir-YZ          18  Vir-ZX          19  Vir-ZY          20  Vir-ZZ        
 21  Pres-XX         22  Pres-XY         23  Pres-XZ         24  Pres-YX       
 25  Pres-YY         26  Pres-YZ         27  Pres-ZX         28  Pres-ZY       
 29  Pres-ZZ         30  #Surf*SurfTen   31  T-rest
"
#Create potential.png
    grace -nxy potential-em-$pdb.xvg -hdevice PNG -hardcopy -printfile potential-em-$pdb.png

#Equilibration at constant temperature
    $exe grompp -f nvt.mdp -c em-$pdb.gro -r em-$pdb.gro -p topol.top -o nvt-$pdb.tpr
        $exe mdrun -deffnm nvt-$pdb -v
	# mpirun -np 64 gmx_mpi_d mdrun -deffnm nvt-$pdb -v  # to run in parallel

#Calculate Temperature
    echo 16 | $exe energy -f nvt-$pdb.edr -o temperature-em-$pdb.xvg

#Create temperature.png
    grace -nxy temperature-em-$pdb.xvg -hdevice PNG -hardcopy -printfile temperature-em-$pdb.png

#Equilibration at constant pressure
    $exe grompp -f npt.mdp -c nvt-$pdb.gro -r nvt-$pdb.gro -t nvt-$pdb.cpt -p topol.top -o npt-$pdb.tpr
        $exe mdrun -deffnm npt-$pdb -v
	# mpirun -np 64 gmx_mpi_d mdrun -deffnm npt-$pdb -v # to run in parallel

#Calculate Pressure
    echo 18 | $exe energy -f npt-$pdb.edr -o pressure-npt-$pdb.xvg

    ##Create pressure.png
        grace -nxy pressure-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile pressure-npt-$pdb.png

#Calculate Density-NPT
    echo 24 | $exe energy -f npt-$pdb.edr -o density-npt-$pdb.xvg

    ##Create density-npt.png
        grace -nxy density-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile density-npt-$pdb.png

#Calculate rmsd-npt
    echo 4 4 | $exe rms -f npt-$pdb.xtc -s npt-$pdb.tpr -o rmsd-npt-$pdb.xvg -tu ns

    ##Create rmsd-npt.png
        grace -nxy rmsd-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile rmsd-npt-$pdb.png

#Calculate rmsf-npt
    echo 4 | $exe rmsf -f npt-$pdb.xtc -s npt-$pdb.tpr -o rmsf-npt-$pdb.xvg -res

    ##Create rmsf-npt.png
        grace -nxy rmsf-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile rmsf-npt-$pdb.png

#Calculate Hbond
    ## Select 1 for acceptor and 1 for donor
        echo 1 1 | $exe hbond -f npt-$pdb.xtc -s npt-$pdb.tpr -num Hbond-npt-$pdb.xvg

    ##Create Hbond-npt.png
        grace -nxy Hbond-npt-$pdb.xvg -hdevice PNG -hardcopy -printfile Hbond-npt-$pdb.png

#MD Production
    $exe grompp -f md.mdp -c npt-$pdb.gro -t npt-$pdb.cpt -p topol.top -o md-$pdb.tpr
        $exe mdrun -deffnm md-$pdb -v
	# mpirun -np 64 gmx_mpi_d mdrun -deffnm md-$pdb -v  # to run in parallel
#Else to use gpu
# gmx_mpi_d mdrun -deffnm md-$pdb -nb gpu

#Analysis
    ## Periodicty correction
        ### select 1 for protein and 0 for system
            echo 1 0 | $exe trjconv -s md-$pdb.tpr -f md-$pdb.xtc -o md-$pdb-noPBC.xtc -pbc mol -center

    ## RMSD calculation : Protein backbone
        ### select 4 for protein backbone
            echo 4 4 | $exe rms -s md-$pdb.tpr -f md-$pdb-noPBC.xtc -o rmsd-md-$pdb.xvg -tu ns

    ## RMSF calculation : Protein backbone
        ### select 4 for protein backbone
            echo 4 | $exe rmsf -s md-$pdb.tpr -f md-$pdb-noPBC.xtc -o rmsf-md-$pdb.xvg -res
            ####Create rmsf-md-$pdb.png
                grace -nxy rmsf-md-$pdb.xvg -hdevice PNG -hardcopy -printfile rmsf-md-$pdb.png

    ## RMSF calculation 1ns: Protein backbone
        ### select 4 for protein backbone
            echo 4 | $exe rmsf -s md-$pdb.tpr -f md-$pdb-noPBC.xtc -o rmsf-md-$pdb-1ns.xvg -res -b 0 -e 1000
            ####Create rmsf-md-$pdb-1ns.png
                grace -nxy rmsf-md-$pdb-1ns.xvg -hdevice PNG -hardcopy -printfile rmsf-md-$pdb-1ns.png

    ## RMSD calculation relative to crystal/initial structure: Protein backbone
        ### select 4 for protein backbone
            echo 4 4 | $exe rms -s em-$pdb.tpr -f md-$pdb-noPBC.xtc -o rmsd-xtal-$pdb.xvg -tu ns
            #### Create rmsd.png from MD production
        grace -block rmsd-md-$pdb.xvg -bxy 1:2 -block rmsd-xtal-$pdb.xvg -bxy 1:2 -hdevice PNG -hardcopy -printfile rmsd-MD-$pdb.png

    ## Radius of Gyration
        ### select 1 for protein
            echo 1 | $exe gyrate -s md-$pdb.tpr -f md-$pdb-noPBC.xtc -o gyrate-md-$pdb.xvg
            ####Create gyrate.png from MD production
                grace -nxy gyrate-md-$pdb.xvg -hdevice PNG -hardcopy -printfile gyrate-md-$pdb.png

    ##Calculate Hbond
        ### Select 1 for acceptor and 1 for donor
            echo 1 1 | $exe hbond -f md-$pdb-noPBC.xtc -s md-$pdb.tpr -num Hbond-md-$pdb.xvg
            ####Create Hbond-npt.png
                grace -nxy Hbond-md-$pdb.xvg -hdevice PNG -hardcopy -printfile Hbond-md-$pdb.png

    ##Calculate DSSP
        export DSSP=/usr/bin/dssp
        echo 1 | $exe do_dssp -f md-$pdb-noPBC.xtc -s md-$pdb.tpr -o dssp-md-$pdb.xpm
    ##Calculate SASA
	echo 1 | $exe sasa -f md-$pdb-noPBC.xtc -s md-$pdb.tpr -o sasa-md-$pdb.xvg -tu ns
