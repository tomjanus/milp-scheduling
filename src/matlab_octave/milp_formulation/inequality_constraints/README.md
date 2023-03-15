## Inequality constraints (for each time-step $k$)

### 1. Linear power consumption model inequality constraint *power_model_ineq_constraint.m*
```math
    \begin{equation}
    (n^j(k)-1) \, U_{power} \le \left( m^j_q \, q^j(k) + m^j_s \,s^j(k) + c^j \right) - p^j(k) \le (1-n^j(k)) \, U_{power}
    \end{equation}
```
The above LHS and RHS inequalities can be represented as:
```math
    \begin{equation}
        \left\{
            \begin{array}{lll}
                -m^j_q \, q^j(k) - m^j_s \,s^j(k) + p^j(k)& \le & U_{power} + c^j \\
                + m^j_q \, q^j(k) + m^j_s \,s^j(k) - p^j(k) & \le & U_{power} - c^j
            \end{array}
        \right. \quad \forall j \in \mathbf{I}_{pumps}
    \end{equation}
```
### 2. Binary linearization of the power consumption variable with respect to pump status - *power_ineq_constraint.m*
```math
\begin{equation}
 0 \le p^j(k) \le n^j(k) \, U_{power}
\end{equation}
```
which translate into the following two single-sided inequalities:
```math
    \begin{equation}
        \left\{
            \begin{array}{lll}
                -p^j(k) & \le & 0 \\
                +p^j(k) - U_{power} \, n^j(k) & \le & 0
            \end{array}
        \right. \quad \forall j \in \mathbf{I}_{pumps}
    \end{equation}
```
### 3. Boundary constraints for pipe segment flows - *pipe_flow_segment_constraints.m*
```math
\begin{equation}
 bb_i^j(k) \, q^j_{i,min} \le ww_i^j(k) \le bb_i^j(k) \, q^j_{i,max}
\end{equation}
```
which translate into the following two single-sided inequalities:
```math
    \begin{equation}
        \left\{
            \begin{array}{lll}
                -ww_i^j(k) +  q^j_{i,min} \, bb_i^j(k) & \le & 0 \\
                +ww_i^j(k) -  q^j_{i,max} \, bb_i^j(k) & \le & 0
            \end{array}
        \right. \quad \forall j \in \mathbf{I}_{pipes} \quad \forall i \in \mathbf{I}_{pipesegments}
    \end{equation}
```
### 4. Linearized pump speed inequality constraint - *s_box_constraints.m*
```math
\begin{equation}
 n^j(k) \, s^j_{min} \le s^j(k) \le n^j(k) \, s^j_{max}
\end{equation}
```
which translate into the following two single-sided inequalities:
```math
    \begin{equation}
        \left\{
            \begin{array}{lll}
               -s^j(k) + s^j_{min} \, n^j(k) & \le & 0 \\
               +s^j(k) - s^j_{max} \, n^j(k)  & \le & 0
            \end{array}
        \right. \quad \forall j \in \mathbf{I}_{pumps}
    \end{equation}
```
### 5. Linearized pump flow inequality constraint - *q_box_constraints.m*
```math
\begin{equation}
 0 \le q^j(k) \le n^j(k) \, q^j_{intcpt}(s^j_{max})
\end{equation}
```
which translate into the following two single-sided inequalities:
```math
    \begin{equation}
        \left\{
            \begin{array}{lll}
               -q^j(k) & \le & 0 \\
               +q^j(k) - q^j_{intcpt}(s^j_{max}) \, n^j(k)  & \le & 0
            \end{array}
        \right. \quad \forall j \in \mathbf{I}_{pumps}
    \end{equation}
```
### 6. Linearized pump hydraulics constraints - *pump_equation_constraints.m*
```math
\begin{equation}
 -(1-n^j(k)) \, U_{pump} \le \Delta h(k) - \Delta h_{pump}(k) \le (1-n^j(k)) \, U_{pump}
\end{equation}
```
where
```math
\begin{equation}
 \Delta h_{pump}(k) = \sum_{i=1}^{n_{s,pump}} \left( dd^j_i \, ss^j_i(k) + ee^j_i \, qq^j_i(k) + ff^j_i \, aa^j_i(k) \right)
\end{equation}
```
which translate into the following two single-sided inequalities:
```math
    \begin{equation}
        \left\{
            \begin{array}{lll}
               -\Delta h(k) + \Delta h_{pump}(k) + U_{pump} \, n^j(k) & \le & U_{pump} \\
               +\Delta h(k) - \Delta h_{pump}(k) + U_{pump} \, n^j(k) & \le & U_{pump}
            \end{array}
        \right. \quad \forall j \in \mathbf{I}_{pumps}
    \end{equation}
```
### 7. Linearized pump characteristic domain constraints - *pump_domain_constraints.m*
```math
\begin{equation}
 m_{ss,i}^n \, ss_i^j(k) + m_{qq,i}^n \, qq_i^j(k) + c_i^n \le 0 \quad \forall i \in \mathbf{I}_{s,pump} \quad \forall j \in \mathbf{I}_{pumps} \quad \forall n \in \{1 \ldots 4\}
\end{equation}
```

