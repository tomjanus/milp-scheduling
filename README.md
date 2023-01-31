<div id="top"></div>

<!-- PROJECT LOGO -->
<p align="center">
    <img alt="dam-opt-logo" src="https://link.us1.storjshare.io/raw/jvyhgzlc5qqh2a44bvn5umvng2jq/milops-wdn/milops-wdn-logo.png"/>
</p>

<!-- ABOUT THE PROJECT -->
## About The Library
This repository contains MATLAB/OCTAVE code for solving optimal pump scheduling problems using piecewise linear approximations of pipes and control elements, and subsequent formulation of the problem as mixed integer linear programming (MILP).

### :fire: Features

## Installation
The package first needs to be installed via the following script `src/matlab_octave/install_milp_scheduler.m`. The script adds paths to the package files in the MATLAB/OCTAVE environment with the set of `ADDPATH()` commands.

## Usage
The pump scheduling code composed of model initialisation, (nonlinear) model simulation with intitial schedule, MILP problem formulation and solution, and final simulation of the nonlinear model with the optimal schedule can be run via `src/matlab_octave/run_scheduling.m`

## License
[MIT](https://choosealicense.com/licenses/mit/)

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
