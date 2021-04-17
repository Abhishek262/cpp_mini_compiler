import fileinput
from pprint import pprint
import re

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
    pprint(leaders)
    pprint(cfg)

    ret_icg = []
    end_arr = []

    for x in range(1,len(leaders)):
        end_arr.append(leaders[x]-1)
        
    end_arr.append(len(icgCode))

    arr = [0 for i in range(len(leaders))]


    for i in range(1,len(leaders)):
        for j in range(0,len(leaders)):
            if(cfg[j][i]==1):
                arr[i] = 1 

    arr[0] = 1
    print(arr)
    for i in range(len(arr)):
        if(arr[i]==0):
            for j in range(leaders[i],end_arr[i]): 
                icgCode[j] = ""
            # del icgCode[leaders[i+1]:arr[i+1]]

    while("" in icgCode) :
        icgCode.remove("")

    return icgCode


# icgCode = dead_code_elim(icgCode)
# pprint(icgCode)

def constant_folding(icgCode):
    #   T2 = 4 * 7',
    #  'T3 = T2 * 9',
    #  'T4 = T3 * 10',
    #  T4 = 7*9*10
    num_array = []
    temp = []
    for i in range(len(icgCode)-1):
        temp_var = icgCode[i].split()[0]
        l = i+1
        line = icgCode[l]
        c = 0

        # print(icgCode[i])
        while(len(line.split())>3 and line.split()[2] == temp_var and "if" not in line and "goto" not in line):

            if(icgCode[i] not in temp ):
                temp.append(icgCode[i])
            if(line not in temp):  
                temp.append(line) 

            temp_var = icgCode[l].split()[0]
            l+=1
            c+=1
            line = icgCode[l]

        if(c>0 and temp[len(temp)-1]!=""):
            temp.append("")

    # print(temp)
    res = []
    x = 0
    s = False
    op = []
    repl_instr = []
    to_del = []
    f = 0
    while(x<len(temp)):
        s = True
        l = []
        f = 0
        while(temp[x]!=""):
            sp = temp[x].split()
            if(s):
                s = False
                l.append(sp[2])
                l.append(sp[3])
                l.append(sp[4])
            else:
                l.append(sp[3])
                l.append(sp[4])
            x+=1       
            f+=1 
        x+=1
        op.append(l)
        to_del.append(f-1)
        repl_instr.append(temp[x-2])
    
    # print("F")
    # print(to_del)

    for lst in op:
        a = "".join(lst)
        res.append(eval(a))

    # print(res)
    # print(repl_instr)
    res_instr = []
    c = 0
    for elem in res :
        s = repl_instr[c].split("=")
        res_i = s[0] + "= "  + str(res[c])
        res_instr.append(res_i)
        c+=1

    for i in range(len(res_instr)):
        for j in range(len(icgCode)):
            if icgCode[j] == repl_instr[i]:
                # print(icgCode[j])
                icgCode[j] = res_instr[i]
                f = to_del[i]
                while(f!=0):
                    icgCode[j-f] = ""
                    f-=1
    while("" in icgCode) :
        icgCode.remove("")

    return icgCode


def constant_propagation(icgCode):
    for line in icgCode:
        l = line.split()
        if len(l) == 3 and "T" not in l[2]:
            for i in range(len(icgCode)):
                if " "+l[0]+" " in icgCode[i]:
                    icgCode[i] = re.sub(" "+l[0]+" "," "+l[2]+" ",icgCode[i])
                elif " "+l[0] in icgCode[i]:
                    icgCode[i] = re.sub(" "+l[0]," "+l[2],icgCode[i])

    return icgCode

def common_subexpression_elim(icgCode):
    for line in icgCode:
        l = line.split()
        if(len(l)==5):
            for i in range(len(icgCode)):
                if l[2] +" "+  l[3] +" "+ l[4] in icgCode[i] and icgCode[i] != line:
                    sp = icgCode[i].split("=")
                    icgCode[i] = sp[0] + "= " + l[0]

    print(icgCode)

pprint(icgCode)
# print(constant_propagation(icgCode))
common_subexpression_elim(icgCode)