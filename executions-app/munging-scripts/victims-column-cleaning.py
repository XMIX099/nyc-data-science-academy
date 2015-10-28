import pandas as pd
executions = pd.read_csv(r'C:\Users\Gordon\Documents\Bootcamp\projects\project2\my-app\data\execution_database.csv')

executions['Number / Race / Sex of Victims'] = executions['Number / Race / Sex of Victims'].map(lambda x: str(x)).map(lambda x: x.replace('(s)','-').strip().rstrip('-')).map(lambda x: x.split('-'))
executions['Male-Victims'] = executions['Number / Race / Sex of Victims'].map(lambda val: sum([int(x[0]) for x in val if x[0].isdigit() if 'Male' in x]))
executions['Female-Victims'] = executions['Number / Race / Sex of Victims'].map(lambda val: sum([int(x[0]) for x in val if x[0].isdigit() if 'Male' in x]))

executions = executions.drop('Number / Race / Sex of Victims',1)
executions.to_csv(r'C:\Users\Gordon\Documents\Bootcamp\projects\project2\my-app\data\executions.data.csv', index = False)

