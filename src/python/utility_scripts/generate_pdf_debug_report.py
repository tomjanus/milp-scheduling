""" Create a PDF report with specification of the MILP problem formulation from
a collection of .report text files."""
from typing import List
import argparse
import logging
import io
import os
from fpdf import FPDF


logging.basicConfig(level=logging.INFO)


def find_files(dir_path: str, ext: str) -> List[str]:
    """ """
    # Make sure extension is in a (dot)ext format, e.g. .docx
    if not ext.startswith("."):
        ext = "".join([".", ext])
    return [
        os.path.join(dir_path, file) for file in os.listdir(dir_path) 
        if file.endswith(ext)]


def write_lines_to_pdf_cell(
        file_handle: io.TextIOWrapper, pdf_object: FPDF, 
        line_width: int = 5) -> None:
    """ """
    for line in file_handle:
        pdf_object.cell(0, line_width, ln=1, txt=line)


def convert_reports_to_pdf(
        reports_folder: str, output_file: str, verbose: bool) -> None:
    """ """
    pdf = FPDF()
    pdf.set_font("Arial", size=10)
    pdf.set_title("MILP formulation report")
    subfolders = (f.path for f in os.scandir(reports_folder) if f.is_dir())
    for subfolder in subfolders:
        if verbose:
            logging.info("Writing reports in folder %s", subfolder)
        report_files = find_files(subfolder, ext=".report")
        for file in report_files:
            pdf.add_page()
            with open(file, "r") as file_handle:
                write_lines_to_pdf_cell(file_handle, pdf)
    pdf.output(output_file)
    if verbose:
        logging.info("Reports saved to file %s", output_file)


if __name__ == "__main__":
    """Run the function in the CLI mode"""
    parser = argparse.ArgumentParser()
    parser.add_argument("reports_folder", help="Path of the reports directories")
    parser.add_argument("output_file", help="Path to the output PDF file")
    parser.add_argument("--verbose", help="Additional output information", 
                        action="store_true")
    args = parser.parse_args()  
    convert_reports_to_pdf(args.reports_folder, args.output_file, args.verbose)
