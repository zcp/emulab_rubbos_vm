#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>

#define window 50
#define maxInt 2147483647
#define minInt -2147483648
#define BucketSize 100000
#define outputResource "_dst"

#define to_token "_TO_"

int main(int argv, char* argc[]) {
	
	if(argv < 2) {
		printf("please specify file to be parsed.\n");
		printf("./WaitTime [filename]\n");
		return 0;
	}
	char node[100] = {0};
	char component[100] = {0};
	char resource[100] = {0};
	char monitor[100] = {0};
	int len = strlen(argc[1]);
	int count = 0;
	int ptr = 0;
	//find TO token
	//look at upstream name first
	//look at downstream name
	//column label should be downstream node_outputResource
	//outputFileName should be same as input except with outputResource
	/*for(int i=0; i<len; ++i) {
		if(argc[1][i] == '_' || argc[1][i] == '.') {
			count += 1;
			if(count == 1) 
				strncpy(node, argc[1]+ptr, i-ptr);
			else if(count == 2)
				strncpy(component, argc[1]+ptr, i-ptr);
			else if(count == 3)
				strncpy(resource, argc[1]+ptr, i-ptr);
			ptr = i+1;
		}
		if(count ==3)
			break;
	}
	if(count != 3) {
		printf("The input filename doesn't match the format\n");
		return 0;
	}*/
	int flag = 1;
	int first_pos_start =0;
	int next_pos_start =0;
 	int first_to_token_char =0;
	int last_part =0;
	
	char * to_ptr = strstr(argc[1],to_token);
	if(to_ptr != NULL ){
		flag = 0;
		first_to_token_char = (int)(to_ptr-argc[1]);
		last_part = first_to_token_char+4;
		for(int i=0; i<len; ++i) {
			if(argc[1][i] == '_') {
                count += 1;
				if(count==4)
					first_pos_start=ptr;
                ptr = i+1;
            }
			if(i > first_to_token_char){
				flag = 1;
				break;			
			} 
            if(count ==4)
                    break;
		}
		for(int i=last_part; i<len; ++i) {
            if(argc[1][i] == '_' || argc[1][i] == '.') {
                    count += 1;
                    if(count == 5) 
    				    strncpy(node, argc[1]+ptr, i-ptr);
                    if(count==8)
                        next_pos_start = ptr;
                    ptr = i+1;
            }
            if(count ==8)
                    break;
        }
		
	}
	
	if(flag == 1 || count!=8){
		printf("The input filename doesn't match the format\n");
		return 0;
	}


	char outputFileName[200] = {0};
	//sprintf(outputFileName, "%s_%s_%s_other-metadata.csv", node, component, resource);
	char firstPartStr[100] = {0};
	char lastPartStr[100] = {0};
	strncpy(firstPartStr, argc[1]+0, first_pos_start);
	strncpy(lastPartStr, argc[1]+last_part, next_pos_start - last_part);
	sprintf(outputFileName, "%s%s%s%s%s.csv",firstPartStr, outputResource,to_token,lastPartStr,outputResource);
	printf("%s\n", outputFileName);

	FILE* ofp = fopen(outputFileName, "w");

	double min, max;
	max = minInt;
	min = maxInt;
	FILE *fp = fopen(argc[1], "r");
	double startTime, endTime, duration, rt;
	int reqid;
	char category[100];
	//get the min and max
	while(fscanf(fp, "%d,%lf,%lf,%s,%lf", &reqid, &startTime, &endTime, category,&rt)!=EOF) {
		if(startTime < min)
			min = startTime;
		if(startTime > max)
			max = startTime;
	}
	//printf("min = %lf, max = %lf\n", min, max);
	min = floor(min);
	max = ceil(max);
	printf("min = %lf, max = %lf\n", min, max);

	rewind(fp);
	int maxBucket = 0;
	double bucketNum[BucketSize];
	double bucketSum[BucketSize];
	for(int i=0; i<BucketSize; i++) {
		bucketNum[i] = 0.0;
		bucketSum[i] = 0.0;
	}
	
	memset(category, 0, sizeof(category));
	while(fscanf(fp, "%d,%lf,%lf,%s,%lf", &reqid, &startTime, &endTime, category,&rt)!=EOF) {
		if(strstr(category, "html")!=NULL) {
			continue;
		}

		//calculate the bucket based on arrving time
		//int bucket = (int)((startTime - min)*1000/window);
		//if(bucket > maxBucket)
		//	maxBucket = bucket;
		//char *durPtr = strchr(category, ',');
		//durPtr++;
		//duration = atof(durPtr);					
		//bucketNum[bucket] += 1.0;
		//bucketSum[bucket] += duration;

		//calculate the bucket based on proportional accounting
		char *durPtr = strchr(category, ',');
		durPtr++;
		duration = atof(durPtr);
		double startTimeCopy = startTime;
		while(startTimeCopy < endTime) {
			int bucket = (int)((startTimeCopy - min)*1000/window);
			if(bucket > maxBucket)
				maxBucket = bucket;
			double minInterval = min + ((double)(window)/1000.0)*((double)(bucket));
			double maxInterval = minInterval + ((double)(window)/1000.0);
			if(minInterval < startTime)
				minInterval = startTime;
			if(maxInterval > endTime)
				maxInterval = endTime;
			double proportional = (maxInterval - minInterval)/(endTime-startTime);
			double proportionalDuration = proportional * duration;
			//Choose One
			//Option A
			bucketNum[bucket] += 1.0;
			//Option B
			//bucketNum[bucket] += proportional;
			bucketSum[bucket] += proportionalDuration;
			startTimeCopy = startTimeCopy + ((double)(window)/1000.0);
		}
	}
	
	//print out the first row
	fprintf(ofp, "timestamp|%s%s\n", node, outputResource);
	printf("max bucket: %d \n",maxBucket);
	for(int i=0; i<maxBucket+1; i++) {
		double timeStamp = min + ((double)((i)*window))/1000.0;
		double average = 0;
		if(bucketNum[i] > 0.00001)
			average = bucketSum[i]/bucketNum[i];
		//printf("%lf,%lf\n",timeStamp, average);
		fprintf(ofp, "%lf|%lf\n", timeStamp, average);
	}

	fclose(fp);

	fclose(ofp);

	return 0;
}
