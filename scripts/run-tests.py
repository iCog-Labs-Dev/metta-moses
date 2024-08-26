import re

from hyperon import MeTTa
import pathlib

# get the list of test metta files from path (mosesReductionPath)
root = pathlib.Path("../")
testMettaFiles = root.rglob("*test.metta")

listOfTestPrograms = []
for mettaFile in testMettaFiles: # for each file in the list
    with open(mettaFile, 'r') as f:
        testContents = f.readlines() # put the lines to a variable (list).

    mettaTestProgram = ''
    for line in testContents: # for each line in the file
        isRegisterModulePresent = re.search("\(register-module!", str(line))
        if (isRegisterModulePresent is None):
            mettaTestProgram += line # join each line to form a program

    listOfTestPrograms.append({
        'fileName': mettaFile.name,
        'program': mettaTestProgram
    }) # collect programs into a list

# listOfTestPrograms[0]['program'] = f"!(register-module! ./) {listOfTestPrograms[0]['program']}"

metta = MeTTa() # initialize MeTTa instance
# print(metta.working_dir())
listOfTestPrograms[0]['program'] = f"!(register-module! {metta.working_dir()}) {listOfTestPrograms[0]['program']}"

programResults = []
for testProgram in listOfTestPrograms: # for each program in the list
    programResults.append({
        'fileName': testProgram['fileName'],
        'expressions': metta.parse_all(testProgram['program']),
        'outputs': metta.run(testProgram['program'])
    }) # collect expression results into a list
# print(programResults)

# testCase = {
#     'fileName': '',
#     'testContent': [],
#     'testOutcome': [
#         {
#             'outcome': '',
#             'output': ''
#         }
#     ],
#     'testsPassed': 0
#     'testsFailed': 0
# }

testCases = []
for programResult in programResults:
    outputCounter = 0
    testCase = {
        'fileName': programResult['fileName'],
        'testContent': [],
        'testOutcome': [],
        'testsPassed': 0,
        'testsFailed': 0
    }
    for idx, expression in enumerate(programResult['expressions']): # for each expression in a program
        if (str(expression)) == '!':
            nextExpression = programResult['expressions'][idx+1] # get the expression for the respective '!'
            isAssertExpression = re.match("\(assertEqual", str(nextExpression))
            if isAssertExpression is not None:
                outputString = str(programResult['outputs'][outputCounter][0])

                testCase['testContent'].append(nextExpression)
                if outputString == '()':
                    testCase['testOutcome'].append({
                        'result': "Pass",
                        'output': programResult['outputs'][outputCounter]
                    })
                    testCase['testsPassed'] += 1
                else:
                    testCase['testOutcome'].append({
                        'result': "Fail",
                        'output': programResult['outputs'][outputCounter]
                    })
                    testCase['testsFailed'] += 1
                    break
                
            outputCounter += 1

    testCases.append(testCase)
# print(testCases)

testsPassed = 0
testsFailed = 0
for testCase in testCases:
    for idx, outCome in enumerate(testCase['testOutcome']):
        if outCome['result'] == "Fail":
            print("Expression: \033[91m {}\033[0m" .format(testCase['testContent'][idx]))
            print("Output: \033[91m {}\033[0m" .format(outCome['output']))
            print("\033[91m=\033[0m"*60)
            print("\n")

    if testCase['testsFailed'] > 0:
        print("\033[41m Fail \033[0m {}" .format(testCase['fileName']))
    elif testCase['testsFailed'] <= 0:
        print("\033[42m Pass \033[0m {}" .format(testCase['fileName']))
    
    testsPassed += testCase['testsPassed']
    testsFailed += testCase['testsFailed']

totalTests = testsPassed + testsFailed
# print("\n")
print("Tests: \033[91m{} failed\033[0m, \033[92m{} passed\033[0m, {} total" .format(testsFailed, testsPassed, totalTests))
