import re

from hyperon import MeTTa
import pathlib

# get the list of test metta files from path (mosesReductionPath)
root = pathlib.Path("./")
testMettaFiles = root.rglob("*test.metta")

listOfTestPrograms = []
for mettaFile in testMettaFiles: # for each file in the list
    with open(mettaFile, 'r') as f:
        testContents = f.readlines() # put the lines to a variable (list).

    mettaTestProgram = ''
    for line in testContents: # for each line in the file
        mettaTestProgram += line # join each line to form a program

    listOfTestPrograms.append({
        'fileName': mettaFile.name,
        'program': mettaTestProgram
    }) # collect programs into a list

metta = MeTTa() # initialize MeTTa instance

programResults = []
for testProgram in listOfTestPrograms: # for each program in the list
    programResults.append({
        'fileName': testProgram['fileName'],
        'expressions': metta.parse_all(testProgram['program']),
        'outputs': metta.run(testProgram['program'])
    }) # collect expression results into a list

# testCase = {
#     'fileName': '',
#     'testContent': [],
#     'testOutcome': [
#         {
#             'outcome': '',
#             'output': ''
#         }
#     ]
# }
testCases = []
for programResult in programResults:
    outputCounter = 0
    testCase = {
        'fileName': programResult['fileName'],
        'testContent': [],
        'testOutcome': []
    }
    for idx, expression in enumerate(programResult['expressions']): # for each expression in a program
        if (str(expression)) == '!':
            nextExpression = programResult['expressions'][idx+1]
            if re.match("\(assertEqual", str(nextExpression)) is not None:
                outputString = str(programResult['outputs'][outputCounter][0])

                testCase['testContent'].append(nextExpression)
                testCase['testOutcome'].append({
                    'result': "Pass" if outputString == '()' else "Fail",
                    'output': programResult['outputs'][outputCounter]
                })
            outputCounter += 1

    testCases.append(testCase)

# print(testCases)

testsFailed = 0
testsPassed = 0
for testCase in testCases:
    for idx, outCome in enumerate(testCase['testOutcome']):
        if outCome['result'] == "Fail":
            testsFailed += 1
            print("Expression: \033[91m {}\033[0m" .format(testCase['testContent'][idx]))
            print("Output: \033[91m {}\033[0m" .format(outCome['output']))
            print("\033[91m=\033[0m"*60)
            print("\n")
        elif outCome['result'] == "Pass":
            testsPassed += 1
    if testsFailed > 0:
        print("\033[41m Fail \033[0m {}" .format(testCase['fileName']))
    elif testsFailed <= 0:
        print("\033[42m Pass \033[0m {}" .format(testCase['fileName']))

totalTests = testsPassed + testsFailed
# print("\n")
print("Tests: \033[91m{} failed\033[0m, \033[92m{} passed\033[0m, {} total" .format(testsFailed, testsPassed, totalTests))
