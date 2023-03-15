## Equality constraints (for each time-step $k$)

### 1. Mass flow balances in network nodes - *nodeq_contraints.m*
```math
    \begin{equation}
        \sum_{m \in \mathbf{Q_{in,j}}} q_p^m(k) - \sum_{n \in \mathbf{Q_{out,j}}} q_p^n (k) - d_j(k) = 0 \quad \forall j \in \mathbf{I}_{nodes} \quad \forall k \in \{1 \ldots N_T\}
    \end{equation}
```
### 2. Headlosses in network pipes - *pipe_headloss_constraints.m*
```math
    \begin{equation}
        h_o^j(k) - h_d^j(k) - \sum_{i=1}^{n_{s,pipe}} {m_i^j \, ww_i^j(k)} - \sum_{i=1}^{n_{s,pipe}} {c_i^j \, bb_i^j(k)} = 0 \quad \forall j \in \mathbf{I}_{pipes} \quad \forall k \in \{1 \ldots N_T\}
    \end{equation}
```
### 3. Link between flows in pump groups (network elements) and flows in (individual) pumps - *pumpgroup_constraints.m*
```math
   \begin{equation}
        \sum_{i=1}^{n_p^j} q_i^j(k) \, n_i^j(k) = q_{el}^j \quad \forall j \in \mathbf{I}_{pumpgroups}
   \end{equation}
```
### 4. Relationship between water mass balance in tanks and tank levels - *ht_constraints.m*
```math
    \begin{equation}
        h_t^j(k) = \left\{
            \begin{array}{ll}
                h_t^j(k-1) - \frac{1}{A_t^j} \, q_{tank}^j(k) = 0 & \mathrm{for} \quad k = 2:N_T\\
                z_t^j + x_0^j & \mathrm{for} \quad k = 1
            \end{array}
        \right. \quad \forall j \in \mathbf{I}_{tanks}
    \end{equation}
```
### 5. Pipe segment flow equality constraint - *ww_constraints.m*
```math
    \begin{equation}
     q_p^j(k) - \sum_{i=1}^{n_{s,pipe}} ww_i^j(k) = 0 \quad \forall j \in \mathbf{I}_{pipes}
    \end{equation}
```
### 6. Pipe segment selection equality constraint - *bb_constraints.m*
```math
    \begin{equation}
     \sum_{i=1}^{n_{s,pipe}} bb_i^j(k) = 1 \quad \forall j \in \mathbf{I}_{pipes}
    \end{equation}
```
### 7. Pump segment flow equality constraint - *qq_constraints.m*
```math
    \begin{equation}
     q^j(k) - \sum_{i=1}^{n_{s,pump}} qq_i^j(k) = 0 \quad \forall j \in \mathbf{I}_{pumps}
    \end{equation}
```
### 8. Pump segment speed equality constraint - *ss_constraints.m*
```math
    \begin{equation}
     s^j(k) - \sum_{i=1}^{n_{s,pump}} ss_i^j(k) = 0 \quad \forall j \in \mathbf{I}_{pumps}
    \end{equation}
```
### 9. Pump segment selection equality constraint - *aa_constraints.m*
```math
    \begin{equation}
     n^j(k) - \sum_{i=1}^{n_{s,pump}} aa_i^j(k) = 0 \quad \forall j \in \mathbf{I}_{pumps}
    \end{equation}
```

