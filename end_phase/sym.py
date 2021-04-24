from pprint import pprint
import fileinput
import re

symCode = []
# symbol : list of [scope, line, type, storage, value]
symbols = {}
with open("sym.txt","r") as foo :
    for line in foo:
        symCode.append(line.strip())

while("" in symCode):
    symCode.remove("")

for line in symCode:
    a = line.split("\t")
    # print(a)
    temp = []
    symbol = a[0].split(":")[1].strip()
    for i in range(1,6):
        temp.append(a[i].split(":")[1].strip())
    
    if(symbol not in symbols.keys()):
        symbols[symbol] = temp  

# print(symbols)

icgCode = []

for line in fileinput.input():
    if(len(line)>100):
        break;
    line = line.rstrip("\n")
    icgCode.append(line)
# pprint(icgCode)

# for line in icgCode:

#symbol : [type,storage,value]
#          2       3      4
symTable = dict()

for line in icgCode:
    if(re.search("T\d =",line)):
        temp = []
        val= 0
        tmpType = ""
        storage = 0
        a = line.split(" = ")
        symbol = a[0].strip()
        #value
        # print(a)

        eval_str = a[1]
        for item in symbols.keys():
            if( item+ " " in a[1]):
                eval_str = eval_str.replace(item,symbols[item][4])
            
        for item in symTable.keys():
            if( item in a[1]):
                eval_str = eval_str.replace(item,str(symTable[item][2]))

        # print(eval_str)

        if("not" in eval_str):
            tmpType = "bool"
            if("False" in a[1]):
                val = "True"
            else:
                val = "False"
        
        else:
            val = eval(eval_str)
            if("." in str(val)):
                tmpType = "double"
            else:
                tmpType = "int"


            


        if(tmpType=="bool"):
            storage = "2"
        elif(tmpType=="int"):
            storage = "4"      

        temp.append(tmpType)
        temp.append(storage)
        temp.append(val)

        symTable[symbol] = temp
            
# print(symTable)
print(" \nICG temporaries \n")
for key,item in symTable.items():
    print("symbol : "+ str(key)," type: " + str(item[0])," storage: "+ str(item[1])," value: " + str(item[2]))


print()
print()