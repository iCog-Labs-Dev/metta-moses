import csv
from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, V
from hyperon.ext import register_atoms
import csv
from hyperon import MeTTa, OperationAtom

def load_csv_data_to_newspace(metta, csv_file_path):
    """
    Reads a CSV file and converts each row into a MeTTa expression.
    The last column is taken as the 'truth value' (or main operator) and
    each preceding column is paired with its header as a sub-expression.
    Empty rows or rows with insufficient columns are skipped.
    Returns a list of parsed MeTTa expressions.
    """
    filename = str(csv_file_path)
    expressions = []
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        try:
            headers = next(reader)
        except StopIteration:
            # Empty file return empty list
            return []

        for row in reader:
            # Skip empty rows
            if not row or len(row) < 2:
                continue
            # build the expression for the row:
            expr = f"({row[-1]} "
            # iterate over each value except the last one
            for i, value in enumerate(row[:-1]):
                if i < len(headers):
                    expr += f" ({headers[i]} {value})"
            expr += ")"
            expressions.append(expr)
    
    # concatenating them parse each expression individually
    parsed_expressions = [metta.parse_single(expr) for expr in expressions]
    return parsed_expressions
           
@register_atoms(pass_metta=True)
def registatom(metta):
    loadCsv = OperationAtom('load_csv', lambda var1: load_csv_data_to_newspace(metta, var1), 
                                 ['Atom', 'Expression'],unwrap=False)
    return {
        r"load_csv": loadCsv
    }




