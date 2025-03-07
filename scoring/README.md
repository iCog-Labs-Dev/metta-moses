# CSV_LOADER_TO_ATOMSPACE
The Atom Space Loader is a Python-based utility that reads a CSV file,
converts it into a structured MeTTa format, and loads it into a designated Atom Space for further processing.
This allows seamless integration of structured data into a MeTTa reasoning environment.

## Features
Reads CSV files and formats them into MeTTa-compatible expressions.

## PreRequsities
1. "Install Hyperon MeTTa"
   `pip install hyperon`
2. "Install CSV"
   `pip install csv`

## Expected CSV Format
The CSV you are planning to load must be in this format and it can have N number of data meaning its not limited to A B C D only
A,B,C,D,Truthvalue
`True,False,True,True,True`
`False,True,True,True,True`

This will be converted into

(True (A True) (B False) (C True) (D True))
(True (A False) (B True) (C True) (D True))

## Testing
The assertEqual checks weather the data that is loaded on the atom space matchs the structure of the csv file and if its correct it return () and if its not it returns what it expected and what it got in return

## Ensure that the python function is registered using get-type
