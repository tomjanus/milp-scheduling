# Module for formulating the mixed integer linear programme structures
## Linearization of model components
### Pipes
<p align="center">
  <img width="450" src="https://user-images.githubusercontent.com/8837107/225596840-bcb9474c-65ae-4444-91a6-40ebb2c1dcc5.png">
</p>

### Pump characteristics
![pump_characteristic_linearization](https://user-images.githubusercontent.com/8837107/225595922-78017fe5-f952-4a8a-aa4c-a8c0cbbdf4b7.svg)
### Pump power consumption


## Cost function
```math
\begin{equation}
 J = \sum_{k=1}^{N_T} \sum_{j=1}^{n_{pumps}} T(k) \; p^j(k) \, \Delta t
\end{equation}
```
## Equality constraints
see documentation [here](equality_constraints/README.md)

## Inequality constraints
see documentation [here](inequality_constraints/README.md)
