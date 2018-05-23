import sys

csv = sys.argv[1]
property = sys.argv[2]
outfile = 'analysis/'+csv+property+'.csv'

with open(outfile,'w') as f:
    with open(csv, 'r') as tab:
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
