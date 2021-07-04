# TURBULENT Dynamics QVec Tool
## Part of [tdLB](https://latticeboltzmann.com)

Turbulent Dynamics specialises in running high-resolution fluid dynamics simulations on supercomputers.  The application decomposes the complete simulation space into smaller grids and each grid is run on one node.  During the simulation each node creates output files independently.  This applicaiton is used to stitch these files together and do some other post processing calculations.

## Documentation
[Documentation](https://turbulentdynamics.github.io/tdLBQVecTool/)


## Getting Started
```
git clone https://github.com/TurbulentDynamics/tdLBQVecTool.git
cd tdLBQVecTool && swift build
./tdLBQVecTool --vorticity --all SmallSampleData/plot_output_np1_gridx44
./tdLBQVecTool --vorticity -u SmallSampleData/plot_output_np1_gridx44/plot.XZplane.V5.step_00000020 
./tdLBQVecTool *
```

There is limit to number of arguments on Linux systems so the following can also be used
```./tdLBQVecTool --all /path/to/rootdir
./tdLBQVecTool --blob "rootdir/*.XZplane*"
./tdLBQVecTool --xzplane rootdir
```
Larger Sample data available in a git-lfs repo 
`git clone https://github.com/TurbulentDynamics/tdQVecRushtonTurbineSampleOutput.git`
```
46M    plot_output_np64_gridx160
131M    plot_output_np8_gridx268
3.4M    plot_output_np8_gridx44
181M    total
```


#The jupyter notebook in the "python" directory can be used to visualise the file created.



![Impeller Vorticity](docs/Impeller_Vorticity.jpg)
