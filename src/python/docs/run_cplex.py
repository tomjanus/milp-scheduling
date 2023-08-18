import pathlib
import argparse
import os
import cplex
import mip
import scipy.io

#MAT_FILE = pathlib.Path("../data/2p1t/2p1t_model.mat")
MPS_FILE = pathlib.Path("../data/2p1t/2p1t.mps")
CPLEX_RESULTS_FILE = pathlib.Path("../outputs/2p1t/x_optim_cplex.mat")
# Parrarel (multihreaded) execution
os_threads = os.cpu_count()

def run_cplex(
        mps_file: pathlib.Path, cplex_result: pathlib.Path, 
        mip_gap: float = 0.001, num_threads: int | None = os_threads,
        mps_lp_convert: bool = True, debug: bool = True) -> None:
    """Reads the milp model saved in the mps_file and saves results to
    a mat file given in cplex_resuts."""
    
    # Convert MPS file to LP file
    if mps_lp_convert:
        # convert mps to lp using the mip package
        instance = mip.Model()
        instance.read(mps_file.as_posix())
        lp_file = mps_file.with_suffix(".lp")
        instance.write(lp_file.as_posix())

    problem = cplex.Cplex()
    problem.parameters.threads.set(num_threads)
    # problem.parameters.benders.strategy = -1
    problem.read(mps_file.as_posix())
    problem.set_problem_type(cplex.Cplex.problem_type.MILP)
    problem.parameters.mip.tolerances.mipgap.set(mip_gap)
    problem.solve()
    x_optim = problem.solution.get_values()
    if debug:
        problem.report()
        problem.print_information()
        print(f"Solution status: {problem.solution.get_status_string()}")
        print(f"Objective value: {problem.solution.get_objective_value()}")
    scipy.io.savemat(cplex_result, {"x": x_optim})

def cli() -> None:
    """ """
    parser = argparse.ArgumentParser(description="Run CPLEX with given arguments")
    parser.add_argument("mps_file", type=pathlib.Path, help="Path to the MPS file")
    parser.add_argument("cplex_result", type=pathlib.Path, help="Path to the CPLEX result file")
    parser.add_argument("--mip_gap", type=float, default=0.001, 
                        help="MIP gap tolerance")
    parser.add_argument("--num_threads", type=int, default=os.cpu_count(), 
                        help="Number of threads to use")
    parser.add_argument("--no_mps_lp_convert", dest="mps_lp_convert", 
                        action="store_false", help="Disable MPS to LP conversion")
    parser.add_argument("--no_debug", dest="debug", action="store_false", 
                        help="Disable debugging mode")
    args = parser.parse_args()

    run_cplex(
        args.mps_file,
        args.cplex_result,
        mip_gap=args.mip_gap,
        num_threads=args.num_threads,
        mps_lp_convert=args.mps_lp_convert,
        debug=args.debug)


if __name__ == "__main__":
    """ """
    cli()
    