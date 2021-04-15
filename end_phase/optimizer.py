import fileinput
from pprint import pprint

icgCode = []

for line in fileinput.input():
    line = line.rstrip("\n")
    icgCode.append(line)
    
def find_basic_blocks(icgCode) : 
    leaders = []
    leaders.append(0)
    c = 0
    c_target = 0
    for line in icgCode : 

        if "goto" in line : 
            if(c+1 <len(icgCode)):
                leaders.append(c+1)

            goto_label = line.split()[-1]

            c_target = 0
            for line2 in icgCode: 
                if (goto_label + ":") in line2 :
                    leaders.append(c_target)
                c_target +=1
        
        c+=1

    leaders.sort()
    leaders  =list(set(leaders))
    return leaders

def create_cfg(icgCode,leaders) : 
    cfg = [[0 for i in range(len(leaders))] for i in range(len(leaders)) ]
    arr = []
    for x in range(1,len(leaders)):
        arr.append(leaders[x]-1)

    arr.append(len(icgCode)-1)

    for i in range(len(leaders)-1):
        line = icgCode[arr[i]]
        if "goto" in line : 
            if "if" in line : 
                cfg[i][i+1] = 1

            label = line.split()[-1]
            for j in range(len(leaders)):
                if (label + ":") in icgCode[leaders[j]]:
                    cfg[i][j] = 1 
        
        else:
            cfg[i][i+1] = 1

    return cfg


def dead_code_elim(icgCode) : 
    
    leaders = find_basic_blocks(icgCode)
    cfg = create_cfg(icgCode,leaders)


    ret_icg = []
    end_arr = []

    for x in range(1,len(leaders)):
        end_arr.append(leaders[x]-1)
        
    end_arr.append(len(icgCode))

    arr = [0 for i in range(len(leaders))]

    for i in range(1,len(leaders)):
        for j in range(0,len(leaders)):
            if(cfg[j][i]==1):
                arr[j] = 1 

    for i in range(len(arr)):
        if(arr[i]==0):
            for j in range(leaders[i],end_arr[i]): 
                icgCode[j] = ""
            # del icgCode[leaders[i+1]:arr[i+1]]

    while("" in icgCode) :
        icgCode.remove("")

    return icgCode


icgCode = dead_code_elim(icgCode)
pprint(icgCode)

