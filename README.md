# Queuing at Bath Rugby Stadium

This repository contains code developed during the V-KEMS Virtual Study Group (13-15 July) by some of the Group 3 members. 

The VSG has focussed on strategies to reduce COVID-19 contagion at large events. 
Group 3 has looked specifically at ticketed outdoor events, taking as prototype a Rugby match in Bath.

## Overview of the Problem
The code simulates arrivals of fans at one of the Bath stadium gates (assuming 25% capacity). 
Plots and statistics are produced concerning the probabilistic distribution of time spent by one person in the queue. This is done by considering
different levels of pre-checking and different average times needed to check a ticket to allow access into the stadium.
This work is coupled with simulations modelling virus spread in the open air (carried out by a different subgroup), although code for the latter is not yet available in this repository.

## How to clone the repository
To download the code on your own device and run it, either:
1) Click on the green `Code` button, hence `Download ZIP`, or
2) From a terminal or the Git Bash, `cd` into your preferred directory and run `git clone https://github.com/dario-domi/Queuing-Bath.git`.

## Brief Description of the Scripts
A detailed description of what each script does is provided within the latter. The code is heavily commented for the sake of eas(y/ier?) understanding.
A brief guide to running the code from scratch is as follows:
- `Main.m` is (unsurprisingly) the main script. Run this, it will simulate the queuing process (eg, when changing levels of prechecking) and produce various summary plots. The code here makes use of the functions specified below.
- `Queue_simulation` is the function simulating one queuing instance and returning summary statistics.
- `Beta_Density_Plot.m` produces a plot of the beta distribution used to model arrival times at the stadium.
- All generated plots are saved in the folder `Pictures`.



