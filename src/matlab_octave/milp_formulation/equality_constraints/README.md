Functions for formulating model equality constraints:
1. *nodeq_contraints.m* - Mass flow balances in network nodes in each time-step $k$:: 
    ```math
        \sum_{i \in \mathbf{Q_{in,j}}} q_{in}^i (k) + \sum_{i \in \mathbf{Q_{out,j}}} q_{out}^i (k) = 0 \quad \forall j \in \mathbf{I}_{nodes} \quad \forall k \in \{1 \ldots 24\}
    ```
2. *pipe_headloss_constraints.m* - Headlosses in network pipes:
    ```math
        h_o^j(k) − h_d^j (k) − sum_i {m_i^j * ww_i^j} - \sum_i {c_i^j * bb_i^j} = 0
    ```
3. *pumpgroup_constraints.m* - Constraints linking flows in pump groups to flows in (individual) pumps:
   ```math
        \sum_i^j (q_i^j) * n_i^j = q_{pumpgroup} \sep \foreach j \in E_{pumps, j}
   ```
4. 
5. 
6. 
7. 
