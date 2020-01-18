Turbulent Dynamics QVec Library
===============================



## Getting Started
```
git clone --recursive https://github.com/TurbulentDynamics/tdQVecTool.git
cd tdQVecTool && swift build
./tdQVecTool -va Tests/TinyTestData
./tdQVecTool -v TD_Rushton_Sample_Output_QVec/plot_slice.XZplane.V_4.Q_4.step_00000200.cut_70
./tdQVecTool *

There is limit to number of arguments on Linux systems so the following can also be used
./tdQVecTool -a /path/to/rootdir
./tdQVecTool --blob "rootdir/*.XZplane*"
./tdQVecTool --xzplane rootdir


#The jupyter notebook in the "python" directory can be used to visualise the file created.
```
