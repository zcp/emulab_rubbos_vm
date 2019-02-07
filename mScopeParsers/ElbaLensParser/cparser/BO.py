#! /usr/bin/env python

import math, time, sys

global stime_epoch
global etime_epoch
global HTTP_multi
global AJP_multi
global CJDBC_multi
global MYSQL_multi
global HTTP_multi_1sec
global AJP_multi_1sec
global CJDBC_multi_1sec
global MYSQL_multi_10ms
global multi_count_in_sec


# process options
if len(sys.argv) == 7:
    timeSpan = sys.argv[1]
    startTime = sys.argv[2]
    endTime = sys.argv[3]
    workload = sys.argv[4]
    workload_type = sys.argv[5]
    node = sys.argv[6]
    print(node)
else:
	print("the input parameters for aggregateResponseTime is not correct")
	exit(0)

# Adjust this part to your data
#--------------------------------------------------------------------------------
# Input file

#plist_file = "QueueLength-Apache.csv"
#plist_file = "QueueLength-Apache4.csv"
#plist_file = "QueueLength-Apache4.csv"
#plist_file = "QueueLength-Apache3.csv"
#plist_file = "QueueLength-Apache4.csv"
#plist_file = "QueueLength-Tomcat.csv"
#plist_file = "QueueLength-Tomcat4.csv"

plist_file = "QueueLength-" + node + ".csv"

# Output files
#output_file =  timeSpan + "_ApacheAll_multiplicity_wl" + workload + "-50ms.csv"
#output_file2 = timeSpan + "_ApacheAll_responsetime_wl" + workload + "-50ms.csv"
#output_file3 = timeSpan + "_ApacheAll_inout_wl" + workload + "-50ms.csv"
#output_file =  timeSpan + "_Apache4_multiplicity_wl" + workload + "-50ms.csv"
#output_file2 = timeSpan + "_Apache4_responsetime_wl" + workload + "-50ms.csv"
#output_file3 = timeSpan + "_Apache4_inout_wl" + workload + "-50ms.csv"
#output_file =  timeSpan + "_TomcatAll_multiplicity_wl" + workload + "-50ms.csv"
#output_file2 = timeSpan + "_TomcatAll_responsetime_wl" + workload + "-50ms.csv"
#output_file3 = timeSpan + "_TomcatAll_inout_wl" + workload + "-50ms.csv"
output_file =  timeSpan + "_" + node + "_multiplicity_wl" + workload+workload_type + "-50ms.csv"
output_file2 = timeSpan + "_" + node + "_responsetime_wl" + workload+workload_type + "-50ms.csv"
output_file3 = timeSpan + "_" + node + "_inout_wl" + workload + workload_type+"-50ms.csv"
#output_file =  timeSpan + "_MysqlAll_multiplicity_wl" + workload + "-50ms.csv"
#output_file2 = timeSpan + "_MysqlAll_responsetime_wl" + workload + "-50ms.csv"
#output_file3 = timeSpan + "_MysqlAll_inout_wl" + workload + "-50ms.csv"

# Start-time and End-time to be processed
#stime_epoch = time.mktime(time.strptime('201011300746', '%Y%m%d%H%M'))
#etime_epoch = time.mktime(time.strptime('201011300749', '%Y%m%d%H%M')) + 59.999999
stime_epoch = time.mktime(time.strptime(startTime, '%Y%m%d%H%M'))
etime_epoch = time.mktime(time.strptime(endTime, '%Y%m%d%H%M')) + 59.999999

# The number of time windows in 1 sec.
#multi_count_in_sec = 20
multi_count_in_sec = 10
#--------------------------------------------------------------------------------

# initialize dictionaries
HTTP_multi = {}
HTTP_multi_1sec = {}
HTTP_multi_longReqs = {}
AJP_multi = {}
AJP_multi_1sec = {}
CJDBC_multi = {}
CJDBC_multi_1sec = {}
MYSQL_multi = {}
MYSQL_multi_1sec = {}
MYSQL_multi_100ms = {}
MYSQL_multi_10ms = {}
HTTP_totalRT = {}
AJP_totalRT = {}
CJDBC_totalRT = {}

MYSQL_totalRT = {}
MYSQL_totalRT2 = {}
HTTP_input = {}
HTTP_output = {}
AJP_input = {}
CJDBC_input = {}
MYSQL_input = {}
MYSQL_input_EXEC = {}
MYSQL_input_1sec = {}
MYSQL_input_100ms = {}
MYSQL_input_10ms = {}
MYSQL_output = {}
MYSQL_output_1sec = {}
MYSQL_output_100ms = {}
MYSQL_output_10ms = {}

#response time
HTTP_in = {}
HTTP_out_rs = {}


def main():
	if 'RO' in workload_type: 
		if 'Mysql' in node:
			models = ["total","SELECT","INSERT","UPDATE","DELETE"]
			models_title = ["total","SELECT","INSERT","UPDATE","DELETE"]
		else:
			models = ["total","StoriesOfTheDay", "Browse","BrowseCategories","BrowseStoriesByCategory","BrowseStoriesInCategory","OlderStories","ViewStory","ViewComment","Search","SearchInStories","SearchInComments","SearchInUsers","jpg","html"]
			models_title = ["total","StoriesOfTheDay", "Browse","BrowseCategories","BrowseStoriesByCategory","BrowseStoriesInCategory","OlderStories","ViewStory","ViewComment","Search","SearchInStories","SearchInComments","SearchInUsers","jpg","html"]
	else:
		if 'Mysql' in node:
			models = ["total","select","SELECT","INSERT","insert","UPDATE","update","DELETE","delete","commit;","SHOW","SET","/bin","#"]
			models_title = ["total","select","SELECT","INSERT","insert","UPDATE","update","DELETE","delete","commit;","SHOW","SET","/bin","#"]
		else:
			models = ["total","StoriesOfTheDay","BrowseCategories","BrowseStoriesByCategory","OlderStories","ViewStory","SubmitStory","StoreStory","ViewComment","PostComment","StoreComment","ModerateComment","StoreModeratorLog","ReviewStories","AcceptStory","RejectStory","Search","RegisterUser","Author","jpg","html"]
			models_title = ["total","StoriesOfTheDay","BrowseCategories","BrowseStoriesByCategory","OlderStories","ViewStory","SubmitStory","StoreStory","ViewComment","PostComment","StoreComment","ModerateComment","StoreModeratorLog","ReviewStories","AcceptStory","RejectStory","Search","RegisterUser","Author","jpg","html"]


	for model in models:
		HTTP_input[model] = {}
		HTTP_output[model] = {}
		HTTP_multi[model] = {}
		HTTP_multi_longReqs[model] = {}
		HTTP_in[model] = {}
		HTTP_out_rs[model] = {}
		for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
			for ms in range(0, multi_count_in_sec):
				ms_time = target_time * multi_count_in_sec + ms
				HTTP_input[model][ms_time] = 0
				HTTP_output[model][ms_time] = 0
				HTTP_multi[model][ms_time] = 0		
				HTTP_multi_longReqs[model][ms_time] = 0		
				HTTP_in[model][ms_time] = [[],[], [], [], []]
				HTTP_in[model][ms_time][0] = 0                   
				HTTP_in[model][ms_time][1] = 0.0
				HTTP_in[model][ms_time][2] = 0
				HTTP_in[model][ms_time][3] = 0
				HTTP_in[model][ms_time][4] = 0
				
				HTTP_out_rs[model][ms_time] = [[],[], [], [], []]
				HTTP_out_rs[model][ms_time][0] = 0                   
				HTTP_out_rs[model][ms_time][1] = 0.0
				HTTP_out_rs[model][ms_time][2] = 0
				HTTP_out_rs[model][ms_time][3] = 0
				HTTP_out_rs[model][ms_time][4] = 0
	
	for line in open(plist_file):
		if "startingTime" in line:
			continue
		parts = line.split(',')
		#reqID = parts[0]
		reqType = parts[2]
		stime = float(parts[0])
		etime = float(parts[1])
		reqRS = etime - stime
		reqRS_tmp = float(parts[3])
		
		protocol = "client"
		model = reqType.strip()
		if protocol == 'client':
			incInOut(stime, model, HTTP_input)
			incInOut(etime, model, HTTP_output)
			addMulti2(stime, etime, stime_epoch, etime_epoch, model, multi_count_in_sec, HTTP_multi)
			if reqRS < 0:
				print(line)
			elif reqRS > 3:
				addMulti2(stime, etime, stime_epoch, etime_epoch, model, multi_count_in_sec, HTTP_multi_longReqs)
				continue
			else:
				incInOutRS(stime, reqRS, stime_epoch, etime_epoch, model,multi_count_in_sec, HTTP_in,True)
				incInOutRS(etime, reqRS, stime_epoch, etime_epoch, model,multi_count_in_sec, HTTP_out_rs,True)

	
	# open files for output
	OUTFILE3 = open("%s" % output_file3, 'w')
	# write headers on output files
	OUTFILE3.write("date_time")
	for model in models_title:
		OUTFILE3.write(",%s_http_start,%s_http_end" %
                      (model, model))
	OUTFILE3.write("\n")

	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
			ms_time_f = float(ms_time) / multi_count_in_sec
			OUTFILE3.write("%f" % ms_time_f)
			for model in models:
				OUTFILE3.write(",%d,%d" %
                               (HTTP_input[model][ms_time], HTTP_output[model][ms_time]))
			OUTFILE3.write("\n")
	OUTFILE3.close()
	
		# open files for output
	OUTFILE4 = open("%s" % output_file, 'w')
	# write headers on output files
	OUTFILE4.write("date_time")
	for model in models_title:
		OUTFILE4.write(",%s_http" %
                      (model))
	OUTFILE4.write(",http_total_longReq")
	OUTFILE4.write(",http_adjustLoad")
	OUTFILE4.write("\n")

	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
			ms_time_f = float(ms_time) / multi_count_in_sec
			OUTFILE4.write("%f" % ms_time_f)
			for model in models:
				OUTFILE4.write(",%f" %
                               (HTTP_multi[model][ms_time]))
			OUTFILE4.write(",%f,%f" % (HTTP_multi_longReqs["total"][ms_time], (HTTP_multi["total"][ms_time] - HTTP_multi_longReqs["total"][ms_time])))
			OUTFILE4.write("\n")
	OUTFILE4.close()

	# open files for output Response time
	OUTFILE2 = open("%s" % output_file2, 'w')
	# write headers on output files
	OUTFILE2.write("date_time")
	for model in models_title:
		OUTFILE2.write(",%s_http" %
                      (model))
	for model in models_title:
		OUTFILE2.write(",%s_http_out_rs" %
                      (model))
	OUTFILE2.write("\n")

	for target_time in range(int(stime_epoch), int(etime_epoch) + 1):
		for ms in range(0, multi_count_in_sec):
			ms_time = target_time * multi_count_in_sec + ms
			ms_time_f = float(ms_time) / multi_count_in_sec
			#OUTFILE1.write("%s" % time.strftime("%Y/%m/%d %H:%M:%S"  ,time.localtime(ms_time_f)))
			for model in models:
				if (HTTP_in[model][ms_time][0] == 0):
					HTTP_in[model][ms_time][1] = 0
				else:
					HTTP_in[model][ms_time][1] = HTTP_in[model][ms_time][1]/HTTP_in[model][ms_time][0]
				### the response time average using etime
				if (HTTP_out_rs[model][ms_time][0] == 0):
					HTTP_out_rs[model][ms_time][1] = 0
				else:
					HTTP_out_rs[model][ms_time][1] = HTTP_out_rs[model][ms_time][1]/HTTP_out_rs[model][ms_time][0]
			OUTFILE2.write("%f" % ms_time_f)	
			for model in models:
				OUTFILE2.write(",%f" %
			                   (HTTP_in[model][ms_time][1]))
			for model in models:
				OUTFILE2.write(",%f" %
			                   (HTTP_out_rs[model][ms_time][1]))
			OUTFILE2.write("\n")
	OUTFILE2.close()
	

def incInOut(inc_time, model, dic_multi):
	inc_time2 = int(math.floor(inc_time * multi_count_in_sec))
	if inc_time2 < stime_epoch * multi_count_in_sec:
		return
	if inc_time2 > etime_epoch * multi_count_in_sec:
		return
	dic_multi['total'][inc_time2] += 1
	dic_multi[model][inc_time2] += 1
	return

def addMulti2(add_from, add_to, stime_epoch, etime_epoch, model,
              multi_count_in_sec, dic_multi):
	if model == 0:
		print('come here  **********************')
	if (add_to < stime_epoch):
	    return
	elif (add_from < stime_epoch):
	    add_from = stime_epoch
	if (add_from > etime_epoch):
	    return
	elif (add_to > etime_epoch):
	    add_to = etime_epoch
	
	add_from2 = int(math.ceil(add_from * multi_count_in_sec))
	add_to2 = int(math.floor(add_to * multi_count_in_sec))
	if (add_from2 <= add_to2):
	    if (add_from2 - 1 >= stime_epoch * multi_count_in_sec):
	        add_prev  = math.ceil(add_from * multi_count_in_sec) - (add_from * multi_count_in_sec)
	        dic_multi['total'][add_from2 - 1] += add_prev
	        dic_multi[model][add_from2 - 1] += add_prev
	    add_post = (add_to * multi_count_in_sec) - math.floor(add_to * multi_count_in_sec)
	    #print "post: index = %d, add amount = %f" % (add_to2, add_post)
	    dic_multi['total'][add_to2] += add_post
	    dic_multi[model][add_to2] += add_post
	    
	    mycounter = 0;
	    
	    while (add_from2 < add_to2):
	        dic_multi['total'][add_from2] += 1.0
	        dic_multi[model][add_from2] += 1.0
	        add_from2 += 1
	        mycounter += 1
	else:
	    res_time2 = (add_to - add_from) * multi_count_in_sec
	    #print "whole: index = %d, add amount = %f" % (add_to2, res_time2)
	    dic_multi['total'][add_to2] += res_time2
	    dic_multi[model][add_to2] += res_time2
	return


def incInOutRS(inc_time, rs, stime_epoch, etime_epoch, model,
             multi_count_in_sec, dic_multi, switch):
    inc_time2 = int(math.floor(inc_time * multi_count_in_sec))
    if inc_time2 < stime_epoch * multi_count_in_sec:
        return
    if inc_time2 > etime_epoch * multi_count_in_sec:
        return
    if(switch):       
        dic_multi['total'][inc_time2][0] += 1
        dic_multi['total'][inc_time2][1] += rs
        dic_multi[model][inc_time2][0] += 1
        dic_multi[model][inc_time2][1] += rs
        if(0.01 <= rs):
            dic_multi['total'][inc_time2][2] += 1
            dic_multi[model][inc_time2][2] += 1             
        if(0.1 <= rs):
            dic_multi['total'][inc_time2][3] += 1
            dic_multi[model][inc_time2][3] += 1
        if(1 <= rs):
            dic_multi['total'][inc_time2][4] += 1
            dic_multi[model][inc_time2][4] += 1              
    else:
        dic_multi['total'][inc_time2] += 1
        dic_multi[model][inc_time2] += 1            
    return





if __name__ == "__main__":
	main()
