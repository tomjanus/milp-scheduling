<div id="top"></div>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<p align="center">
    <img alt="dam-opt-logo" src="https://link.us1.storjshare.io/raw/jvyhgzlc5qqh2a44bvn5umvng2jq/milops-wdn/milops-wdn-logo.png"/>
</p>

<!-- ABOUT THE PROJECT -->

## About The Library
This repository contains code for solving optimal pump scheduling problems in Water Distribution Networks using mixed integer linear programming (MILP). It can run the MILP problem internally within MATLAB or save the formulated mixed integer linear programme into a `.mps` file for solving outside MATLAB with one of the alternative MILP solvers. The library supports solving `.mps` files using CPLEX and CBC using their respective Python APIs. The Python source code for solving `.mps` files with CPLEX and CBC within Jupyter notebook is available in [/src/python/docs/solve_with_cplex_cbc.ipynb](https://github.com/tomjanus/milp-scheduling/blob/main/src/python/docs/solve_with_cplex_cbc.ipynb).

Most of the code is compatible with both MATLAB and OCTAVE, except for the solution of mixed integer linear programme which only supports MATLAB, as described in the previous paragraph. For mixed integer linear programming, MATLAB uses a built-in solver called `intlinprog` https://uk.mathworks.com/help/optim/ug/intlinprog.html. The code was tested in **MATLABR2022b**.

This repository is currently suited for research purposes only. It was created to facilitate running a feasibility study on the application of MILP in pump scheduling. The authors are working on the improvemet of computational time via reduction of the problem size, e.g. via decomposition and introduction of special ordered sets for modelling piece-wise linear functions.

### Methodology
Solution of the pump scheduling problem using mixed integer linear programming follows a methodology illustrated below.
<p align="center">
  <img width="800" src="https://user-images.githubusercontent.com/8837107/225783212-776a4d10-9c81-4ccd-a6a0-610bcf9f3662.png">
</p>

First, the network is solved using initial schedules in order to obtain approximate operating points that can assist in model linearization.
Second, nonlinear network componentes are linearized using linear and piecewise linear approximations. The nonlinear model components are pipe characteristics, pump characteristics and pump power consumption models. Subsequently, the model is implemented as a mixed integer linear problem of the following form and solved for a time horizon of K=24 hours.

```math
\begin{equation}
\begin{aligned}
\min_{\mathbf{x}} \quad & \mathbf{c}^T\,\mathbf{x}\\
\textrm{s.t.} \quad & \mathbf{A}_{ineq}\,\mathbf{x} \le \mathbf{b}_{ub}\\
  & \mathbf{A}_{eq}\,\mathbf{x} = \mathbf{b}_{eq}\\
  & \mathbf{l} \le \mathbf{x} \le \mathbf{u}\\
  &x_i \in \mathbb{Z}, \forall_i \in \varUpsilon   \\
\end{aligned}
\end{equation}
```
The optimal schedule of pump on/off statuses and pump speeds is input into the full (nonlinear) network model. The results of the final simulation with optimal schedules are then compared against the results obtained with initial schedules.

## Water Distribution Network Model
Water network model is composed of the pipe-network model, the pump model and the head-volume relationships in tank nodes. 
The first is described with a systems of `Kirchoff's` equations for flow continuity in nodes and headlosses in pipe elements.
The pump model descibes pump head as a function of flow, pump speed and the number of pumps working in parallel.
Tanks are represented as nodes in which head is calculated as a function of the net water mass balance, i.e. the volume of water entering/leaving the reservoir in each time step.
Additionally, power consumption in each pump (or pump group) is quantified for the purpose of calculating the network's operating costs.

### Mass balance in nodes
Mass balance in nodes for each time step $k \in \\{1 \ldots K\\}$ is calculated as
```math
\begin{equation}
 \Lambda_c\,q(k)=d(k) \quad \mathrm{for}
\end{equation}
```
where $\Lambda_c$ is the node-element incidence matrix for the connection nodes, $q$ is the vector of element flows and $d$ is the matrix of nodal demands.

### Headlosses in network elements
Nodal pressures in the network are modelled as follows
```math
\begin{equation}
 R \left|q(k)\right| q(k) + \Lambda_c^T h_c(k) + \Lambda_f^T\, h_f(k) = 0
\end{equation}
```
where $\Lambda_c$ and $\Lambda_f$ are node-element incidence matrices for the connection nodes and the fixed nodes, respectively, $h_c$ are the calculated heads and $h_f$ are the fixed heads, e.g. heads in reservoirs.
The above equation can be split into multiple equtions, each representing a single pipe $j$ for $j \in \langle1,\ldots,|\mathbb{P}|\rangle$ where $\mathbb{P}$ denotes the set of pipes.
```math
\begin{equation}
 \underbrace{R_j \left|q_j(k)\right| q(k)}_\textrm{pipe characteristic} + \Lambda_{c,j}^T h_c(k) + \Lambda_{f,j}^T\, h_f(k) = 0
\end{equation}
```
where
$\Lambda_{c,j}^T h_c(k) = h_{d,j}(k)$ and $\Lambda_{f,j}^T\, h_f(k) = h_{o,j}(k)$

### Pump power consumption
Power consumption of a group of $n$ identical pumps each operating at speed $s$ is described as follows:
```math
\begin{equation}
 P(q,n,s) = n\,s^3\,P\left(\frac{q}{n\,s}\right)
\end{equation}
```
where
```math
\begin{equation}
 P\left(\frac{q}{n\,s}\right) = a_3\left(\frac{q}{n\,s}\right)^3 + a_2 \left(\frac{q}{n\,s}\right)^2 + a_1 \left(\frac{q}{n\,s}\right) + a_0
\end{equation}
```
in which the coefficients $a_3$, $a_2$, $a_1$, $a_0$ are parameters of the pump consumption characteristic specific for each individual pump model.
### Pump hydraulic characteristic
Pump head is described by the pump characteristic surface $H_j=H_j(s_j, q_j)$ where $q_j$ is the pump flow and $s_j$ is the pump speed in pump element $j$.
```math
\begin{equation}
 \frac{H}{n^2\,s^2} = A \, \left( \frac{q}{n\,s} \right)^2 + B \left( \frac{q}{n\,s} \right) + C
\end{equation}
```
which can translates into
```math
\begin{equation}
 H = A \, q^2 + B \, q \, n \, s + C \, n^2 \, s^2
\end{equation}
```
### Tank model
```math
\begin{equation}
h_t^j(k)-h_t^j(k-1) - \frac{1}{A_t^j} \, q_t^j(k) = 0 \quad \forall j \in \mathbb{E}_{tank} \quad \forall k = 2\ldots K
\end{equation}
```

```math
\begin{equation}
 h_t^j(1) = h_{t,init}^j \quad \forall j \in \mathbb{E}_{tank}
\end{equation}
```
in which the tank heads are constrained between the minimum and the maximum values:
```math
\begin{equation}
 h_t^j(k) \le h^j_{t,max}(k) 
\end{equation}
```

```math
\begin{equation}
 -h_t^j(k) \le -h^j_{t,min}(k)
\end{equation}
```
for all $j \in \{1,\ldots, n_t\}$ and $k \in \{1, \ldots, K\}$.

## Formulation of the mixed integer linear programme
### Objective function and component linearizations
see documentation [here](src/matlab_octave/milp_formulation/README.md)
### Equality constraints
see documentation [here](src/matlab_octave/milp_formulation/equality_constraints/README.md)
### Inequality constraints
see documentation [here](src/matlab_octave/milp_formulation/inequality_constraints/README.md)
## Installation
The package requires to be installed prior to use. To install the package, execute 
```matlab
src/matlab_octave/install_milp_scheduler.m
```
The script adds paths to the package files to the MATLAB/OCTAVE environment with the set of `ADDPATH()` commands allowing to run individual functions from anywhere in the directory tree.

## Usage
This repository contains code that is intended to be used as an API for custom optimization scenarios. Therefore, all functions are directly accessible from command-line and from within script files. Currently, the repository contains one case study in `src/matlab_octave/case_studies/two_pump_one_tank/` that optimizes pump schedules in a simple two-pump-one-tank network.

The repository was written in two languages: (1) MATLAB code contains majority of the code that simulates the network, formulates the mixed integer linear programme, find optimal schedule with MATLAB's `intlinprog` and performs final visualisation. (2) Python code is used to find optimal schedule using CPLEX and CBC solvers.

The case study can be run in two ways: (1) In a single-step using MATLAB's `intlinprog` solver and (2) in three steps using an external solver, i.e. CPLEX or CBC. The intermediate step will need to be performed outside MATLAB/OCTAVE by executing the Jupyter notebook in [/src/python/docs/solve_with_cplex_cbc.ipynb](https://github.com/tomjanus/milp-scheduling/blob/main/src/python/docs/solve_with_cplex_cbc.ipynb).

#### Method 1
Execute script:
```matlab
run_2p1t_with_matlab
```
in the command prompt from within `/src/matlab_octave/` directory. This command will run the network with initial schedules, linearize the model, formulate and then solve the mixed-integer linear programme and, finally, simulate the network with the optimized pump schedules.

#### Method 2
**Step 1** Execute script:
```matlab
run_2p1t_without_matlab_1.m
```
This command will run the network with initial schedules, linearize the model, and formulate the mixed integer linear programme that is saved into `src/python/data/2p1t/2p1t.mps`. It will also save intermediate results, i.e. some of the workspace variables to `optim_step1.mat` as they will be needed for further processing in the third step.

**Step 2** Optimize pump schedules using Jupyter notebook and CPLEX/CBC Python API:
Run Jupyter notebook in `/src/python/docs/solve_with_cplex_cbc.ipynb`. The notebook will produce optimal/sub-optimal state vector $x$ and save it either to `src/python/outputs/2p1t/x_optim_cplex.mat` or `src/python/outputs/2p1t/x_optim_cbc.mat` depending on the choce of solver.

**Step 3** Execute script:
```matlab
run_2p1t_without_matlab_2.m
```
This script will read the optimization results and the required workspace variables from step 1, simulate the network with the optimized pump schedules and plot the final results.

### Tests
To run tests, navigate to `/tests/matlab_octave/` and run the `run_tests.m` script

### Human-readable representation of the linear programme
To see a human-readable representation of the linear programme cost function and the equality and inequality constraints, navigate to `tests/matlab_octave/debug_2p1t/` and execute the `run_debug.m` script. The script will create folders with text files in `tests/matlab_octave/debug_2p1t/reports/` containing detailed information about all of the components of the linear programme formulation.

Alternatively, you can view text representations of the linear programme either in `.mps` or `.lp` formats. MPS files are created automatically when the case study is run either with or without matlab and the file is saved to `src/python/data/2pt1/2p1t.mps`. The MPS file can be converted to LP file in the Jupyter notebook in `/src/python/docs/solve_with_cplex_cbc.ipynb` and will be saved in the same folder as the MPS file.

## Case study
The case study uses a simple network with two identical pumps in parallel and one tank, shown below.
<p align="center">
  <img width="550" src="https://user-images.githubusercontent.com/8837107/225469098-78fdbaa2-270f-4b79-9b6d-182627d32920.svg">
</p>

The pump schedule, i.e. the number of working pumps and the pump speed, was optimized for the time horizon of 24 hours. The pump schedules, flows in selected network elements, heads in selected nodes and the operating cost are shown in figures below. The figures are listed in three columns showing, respectively, outputs from simulation model using initial schedules, outputs from the MILP model, outputs from the simulation model using optimized schedules.

### Optimization times
Three solvers were tried in this case study: (1) MATLAB's `intlinprog` solver shipped with MATLAB's Optimization Toolbox, (2) IBM's commercial `ILOG CPLEX` solver (free for academic use) and (3) COINOR free open-source CBC (coinor branch and cut) solver.

MATLAB's solver performed the worst with run times over 1 hour and slow convergence (narrowing of the MIP optimality gap). For this reason, using MATLAB's `intlinprog` is not feasible. CPLEX perfomed the best and provided optimal solution with objective value 60.5 GBP for the pump running cost in around 2 seconds. CBC was able to produce a sub-optimal solution of 65 GBP within approx. 60 seconds. We have not attempted to run an exhaustive search with CBC in order to find a solution with proven optimality.

### Results
#### Pump schedules
![schedule_compared](https://user-images.githubusercontent.com/8837107/225469274-9a0031d5-3bd0-4044-ae8a-5afe834e0d6e.svg)
#### Flows in selected elements
![flows_compared](https://user-images.githubusercontent.com/8837107/225469312-8e59c44b-068d-4298-9a48-43ed96aadd8e.svg)
#### Heads at selected nodes
![heads_compared](https://user-images.githubusercontent.com/8837107/225469461-4d645b7e-7663-4cb7-9bf5-d01f8d5f9d56.svg)
#### Operating cost
![cost_compared](https://user-images.githubusercontent.com/8837107/225469386-4f7fa3e4-a97c-4231-a5a6-37b0de04a87a.svg)

## License
[GPL-3.0](https://choosealicense.com/licenses/gpl-3.0/)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CITING -->

## Citing

If you use MILOPS-WDN for academic research, please cite the library using the following BibTeX entry.

```
@misc{milops-wdn2023,
 author = {Tomasz Janus, Bogumil Ulanicki},
 title = {MILOPS-WDN: Mixed Integer Linear Optimal Pump Scheduler for Water Distribution Networks},
 year = {2023},
 url = {https://github.com/tomjanus/milp-scheduling},
}
```
<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTACT -->

## :mailbox_with_mail: Contact
- Tomasz Janus - tomasz.janus@manchester.ac.uk
- Bogumil Ulanicki - bul@dmu.ac.uk

Project Link: [https://github.com/tomjanus/milp-scheduling](https://github.com/tomjanus/milp-scheduling)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## References
[1] [Practical Guide for Solving Difficult Mixed Integer Linear Problems](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwiHlNjj4Y3_AhWhVqQEHUWuBRoQFnoECCwQAQ&url=https%3A%2F%2Fwww.researchgate.net%2Fprofile%2FMohamed-Mourad-Lafifi%2Fpost%2FHow_to_retrieve_explored_node_and_the_number_of_added_user_defined_valid_cut_when_solving_mip_problem_with_solver_Gurobi%2Fattachment%2F5ff5a1bad6d0290001a2e52d%2FAS%253A976944980033538%25401609933242569%2Fdownload%2FPractical%2BGuidelines%2Bfor%2BSolving%2BDifficult%2BMixed%2BInteger%2BLinear%2BPrograms.pdf&usg=AOvVaw3wTwJ2_gRZzrmiRp4Mh9qz)

## Contributors ✨

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/tomjanus"><img src="https://avatars.githubusercontent.com/tomjanus" width="100px;" alt=""/><br /><sub><b>Tomasz Janus</b></sub></a><br /><a href="https://github.com/tomjanus/milp-scheduling/commits?author=tomjanus" title="Code">💻</a><a href="https://github.com/tomjanus/milp-scheduling/commits?author=tomjanus" title="Tests">⚠️</a> <a href="https://github.com/tomjanus/milp-scheduling/issues/created_by/tomjanus" title="Bug reports">🐛</a><a href="#design-TJanus" title="Design">🎨</a><a href="" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/bulanicki"><img src="https://avatars.githubusercontent.com/bulanicki" width="100px;" alt=""/><br /><sub><b>Prof. Bogumil Ulanicki</b></sub></a><br /><a href="https://github.com/tomjanus/milp-scheduling/commits?author=bulanicki" title="Code">💻</a><a href="https://github.com/tomjanus/milp-scheduling/commits?author=bulanicki" title="Tests">⚠️</a></td>
  </tr>
</table>


<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/tomjanus/milp-scheduling.svg?style=plastic
[contributors-url]: https://github.com/tomjanus/milp-scheduling/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/tomjanus/milp-scheduling.svg?style=plastic
[forks-url]: https://github.com/tomjanus/milp-scheduling/network/members
[stars-shield]: https://img.shields.io/github/stars/tomjanus/milp-scheduling.svg?style=plastic
[stars-url]: https://github.com/tjanus/milp-scheduling/stargazers
[issues-shield]: https://img.shields.io/github/issues/tomjanus/milp-scheduling.svg?style=plastic
[issues-url]: https://github.com/tomjanus/milp-scheduling/issues
[license-shield]: https://img.shields.io/github/license/tomjanus/milp-scheduling.svg?style=plastic
[license-url]: https://github.com/tomjanus/milp-scheduling/blob/master/LICENSE
