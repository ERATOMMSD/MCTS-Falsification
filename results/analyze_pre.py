import sys
import os

def listdir(path):
    L = []
    for file in os.listdir(path):
	if os.path.splitext(file)[1] == '.csv':
	    L.append(file)
    return L

testpath = '.'
newfile = 't.csv'
list_name = listdir(testpath)
list_name.sort()

with open(newfile,'a') as f:
    head = open(testpath+'/'+list_name[0],'r').readlines()[0].strip()
    f.write(head)	
    f.write('\n')
    for tb in list_name[0:]:
	with open(testpath + '/' + tb,'r') as ftb:
	    linenum = 0
	    for line in ftb.readlines():
		if linenum == 0:
		    linenum = 1
		else:
		    data = line.strip()
        	    f.write(data)
		    f.write('\n')



i = 0
pp = ['a1','b1','a2','b2','afc261','afc262','afc263','afc27','afc29','afc32','afc33']

for property in pp:
    outfile = 'experiment/MMSD-FLSTar-'+property+'.csv'
    

    with open(outfile,'w') as f:
        with open('t.csv', 'r') as tab:
	    status = 0
	    row = ''
	    lines = tab.readlines()
	    fal = 0
	    time = 0.0
	    fal_pre = 0
	    time_pre = 0.0
	    fal_post = 0
	    time_post = 0.0
	    f.write(lines[0].strip()+'\n')
	    for line in lines[1:]:
	        data = line.strip().split(';')
	        if property in data[0]:
		    status = status + 1
		    fal = fal + int(data[10])
		    time = (time + float(data[11])) if int(data[10])==1 else time
		    fal_pre = fal_pre + int(data[12])
		    time_pre = (time_pre + float(data[13])) if int(data[12])==1 else time_pre
		    fal_post = fal_post + int(data[14])
		    time_post = (time_post + float(data[15])) if int(data[14])==1 else time_post
		    if status == 10:
		        status = 0
		        time = (time/fal) if fal!=0 else -1
		        time_pre = (time_pre/fal_pre) if fal_pre!= 0 else -1
		        time_post = (time_post/fal_post) if fal_post!=0 else -1
		        row = ';'.join(data[0:10]) + ';'+str(fal)+';'+str(time)+';'+str(fal_pre)+';'+str(time_pre)+';'+str(fal_post)+';'+str(time_post)
		        f.write(row+'\n')
		        fal = 0
		        time = 0
		        fal_pre = 0
		        time_pre = 0
		        fal_post = 0
		        time_post = 0
