Functions for formulating model equality constraints:
1. *nodeq_contraints.m* - Mass flow balances in network nodes: 
    ```math
        \sum q_{in}^j (k) + \sum q_{out}^j (k) = 0
    ```
2. *pipe_headloss_constraints.m* - Headlosses in network pipes:
    ```math
        h_o^j(k) − h_d^j (k) − sum_i {m_i^j * ww_i^j} - \sum_i {c_i^j * bb_i^j} = 0
    ```
3. *pumpgroup_constraints.m* - Constraints linking flows in pump groups to flows in (individual) pumps:
   ```math
        \sum_i^j (q_i^j) * n_i^j = q_{pumpgroup} \sep \foreach j \in E_{pumps, j}
   ```
