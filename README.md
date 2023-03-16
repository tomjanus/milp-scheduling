<div id="top"></div>

<!-- PROJECT LOGO -->
<p align="center">
    <img alt="dam-opt-logo" src="https://link.us1.storjshare.io/raw/jvyhgzlc5qqh2a44bvn5umvng2jq/milops-wdn/milops-wdn-logo.png"/>
</p>

<!-- ABOUT THE PROJECT -->

## About The Library
This repository contains code for solving optimal pump scheduling problems in Water Distribution Networks using mixed integer linear programming (MILP). Most of the code is compatible with both MATLAB and OCTAVE, however it requires a mixed integer linear solver which currently is only available in MATLAB. For mixed integer linear programming, MATLAB uses a built-in solver called `intlinprog` https://uk.mathworks.com/help/optim/ug/intlinprog.html. The code was tested in **MATLABR2022b**.

This repository is currently suited for research purposes only. It was created to facilitate running a feasibility study on the application of MILP in pump scheduling. The authors are working on the improvemet of computational time via reduction of the problem size, e.g. by decomposing the problem into sub-problems. We are also looking into testing different solvers, e.g. large scale commercial solvers, parallel solvers, etc.

### Methodology
Solution of the pump scheduling problem using mixed integer linear programming follows a methodology illustrated below.
<p align="center">
  <img width="800" src="https://user-images.githubusercontent.com/8837107/225469001-c06c087b-7960-4229-b05b-a43d307a13fd.png">
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
Water network model is composed of the pipe-network model and the pump model. 
The first is described with a systems of `Kirchoff's` equations for flow continuity in nodes and headlosses in pipe elements.
The pump model descibes pump head as a function of flow, pump speed and the number of pumps working in parallel.
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
## Formulation of the mixed integer linear programme
### Component linearizations
[provide link]
### Objective function
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

The case study can be run as follows. First, execute:
```matlab
[optim_output,init_sim_output,optim_sim_output,sim,input,vars] = run_scheduling_2p1t()
```
in command prompt or from within a script. This command will run the network with initial schedules, linearize the model, formulate and then solve the mixed-integer linear programme and, finally, simulate the network with the optimized pump schedules. The function outputs the optimization output struct `optim_out`, initial simulation output struct `init_sim_output`, optimized simulation output struct `optim_sim_output`, simulation configuration parameters `sim`, input structure `input` and decision variable strucure `vars`.
To visualise the results, run:
```matlab
plot_scheduling_2p1t_results(init_sim_output,optim_output,optim_sim_output,input,sim,vars)
```
### Tests
To run tests, navigate to `/tests/matlab_octave/` and run the `run_tests.m` script

### Human-readable representation of the linear programme
To see a human-readable representation of the linear programme cost function and the equality and inequality constraints, navigate to `tests/matlab_octave/debug_2p1t/` and execute the `run_debug.m` script. The script will create folders with text files in `tests/matlab_octave/debug_2p1t/reports/` containing detailed information about all of the components of the linear programme formulation.

## Case study
The case study uses a simple network with two identical pumps in parallel and one tank, shown below.
<p align="center">
  <img width="600" src="https://user-images.githubusercontent.com/8837107/225469098-78fdbaa2-270f-4b79-9b6d-182627d32920.svg">
</p>

### Pump schedules
![schedule_compared](https://user-images.githubusercontent.com/8837107/225469274-9a0031d5-3bd0-4044-ae8a-5afe834e0d6e.svg)
### Flows in selected elements
![flows_compared](https://user-images.githubusercontent.com/8837107/225469312-8e59c44b-068d-4298-9a48-43ed96aadd8e.svg)
### Heads at selected nodes
![heads_compared](https://user-images.githubusercontent.com/8837107/225469461-4d645b7e-7663-4cb7-9bf5-d01f8d5f9d56.svg)
### Operating cost
![cost_compared](https://user-images.githubusercontent.com/8837107/225469386-4f7fa3e4-a97c-4231-a5a6-37b0de04a87a.svg)

## License
[GPL-3.0](https://choosealicense.com/licenses/gpl-3.0/)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CITING -->

## Citing

If you use MILOPS-WDN for academic research, please cite the library using the following BibTeX entry.

```
@misc{milops-wdn2023,
 author = {Bogumil Ulanicki, Tomasz Janus},
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

