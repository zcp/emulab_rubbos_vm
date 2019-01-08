#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//#define InputFileName "HTTPD.log"
#define InputFileName "access.log"
#define OutputFileName "Tomcat-pit.csv"
#define OutputFileName2 "Tomcat-dst.csv"
#define QueueLengthName "QueueLength-Tomcat.csv"
#define resource1 "request"

#define max_name_length 1000
#define max_line_length 10000
#define max_id_length 20
#define max_timestamp_length 50
#define max_category_length 30

#define id_length 16
//useage: .Apacheparser.o access_log
/*
bool getID(char str[], char id[])
{
	memset(id, 0, sizeof(id));
	char *ptr = strstr(str, "urlID=");
	if(ptr==NULL)
		return false;
	ptr = ptr + 6;	
	for(int i=0; i<id_length; i++)
		id[i] = ptr[i];
	id[id_length] = 0;
	return true;
}
*/

bool getID(char str[], char id[])
{
        memset(id, 0, max_id_length);
        char *ptr = strstr(str, "urlID=");
        if(ptr==NULL)
                return false;
        ptr = ptr + 6;
        int idx = 0;
        for(idx=0; idx<max_id_length; idx++)
        {
                if (ptr[idx] == ' ' || ptr[idx] == '\n') break;
                id[idx] = ptr[idx];
        }

        if (idx >= max_id_length) idx = 19;
        id[idx] = 0;
        return true;
}


bool getTCST(char str[], char tcst[])
{
	memset(tcst, 0, sizeof(tcst));
	char *ptr = strstr(str, "TCST(us)=");
	if(ptr==NULL)
		return false;
	
	sscanf(ptr, "TCST(us)=%s ", tcst);

	return true;
}

bool getTCET(char str[], char tcet[])
{
	memset(tcet, 0, sizeof(tcet));
	char *ptr = strstr(str, "TCET(us)=");
	if(ptr==NULL)
		return false;

	sscanf(ptr, "TCET(us)=%s ", tcet);

	return true;
}

bool getST(char str[], char st[])
{
	memset(st, 0, sizeof(st));
	char *ptr = strstr(str, "ST(us)=");
	if(ptr==NULL)
		return false;
	
	sscanf(ptr, "ST(us)=%s ", st);

	return true;
}

bool getET(char str[], char et[])
{
	memset(et, 0, sizeof(et));
	char *ptr = strstr(str, "ET(us)=");
	if(ptr==NULL)
		return false;

	sscanf(ptr, "ET(us)=%s ", et);
	
	return true;
}

bool getCategory(char str[], char category[])
{
	memset(category, 0, sizeof(category));
	char *ptr2;
	ptr2 = strstr(str, "?");
	char *ptr;
	ptr = ptr2;
	while(ptr[0] != '.')
		ptr = ptr - 1;
	int counter = ptr2 - ptr - 1;
	strncpy(category, ptr+1, counter);
	category[counter] = 0;
	return true;	
}

void getTimeInterval(char time1[], char time2[], char rt[])
{
	//here we assume length1 == length2, and time2 >= time1
	memset(rt, 0, sizeof(rt));
	int length1 = strlen(time1);
	int length2 = strlen(time2);	
	int carry = 0;
	for(int i=length2 - 1; i >=0; i--)
	{
		int tmp = (time2[i] - time1[i]) - carry;
		carry = 0;
		while(tmp < 0)
		{
			tmp = tmp + 10;
			carry = carry + 1;
		}
		rt[i] = tmp + '0';
	}
	rt[length2] = 0;
}

int main(int argc, char *argv[])
{
	FILE *fp, *fp2, *fp3;
	char inFileName[max_name_length] = {0}; 
	if(argc == 2) 
		strncpy(inFileName, argv[1], max_name_length);	
	else
		strncpy(inFileName, InputFileName, max_name_length);
	char outFileName1[max_name_length] = {0};
	int ptr = 0;
	int count = 0;
	for(ptr=0; ptr<strlen(inFileName); ++ptr) {
		if(inFileName[ptr] == '_')
			count += 1;
		if(count == 3)	
			break;
	}
	ptr+=1;
	strncpy(outFileName1, inFileName, ptr);
	strncat(outFileName1, resource1, max_name_length);
	strncat(outFileName1, ".csv", max_name_length);
	printf(outFileName1);
	printf("\n");
/*	if(argc==4)
	{
		fp = fopen(argv[1], "r");
		fp2 = fopen(argv[2], "a");
	}
	else
	{
		fp = fopen(InputFileName, "r");
		fp2 = fopen(OutputFileName, "a");
	}
*/
	fp = fopen(inFileName, "r");
	fp2 = fopen(outFileName1, "w");
	fp3 = fopen(QueueLengthName, "a");
	
	char str[max_line_length];
	memset(str, 0, sizeof(str));
	char id[max_id_length];
	char tcst[max_timestamp_length];
	char tcet[max_timestamp_length];
	char st[max_timestamp_length];
	char et[max_timestamp_length];
	char tcrt[max_timestamp_length];
	double stimestamp, etimestamp, rt;
	char category[max_category_length];
	bool flag;

	if(fp2 == NULL)
	{
		printf("Can't open output file\n");
		return 0;
	}

	while(fgets(str, max_line_length, fp))
	{
		if(getID(str, id)==false)
		{
			printf("Error : when looking for id\n%s", str);
			continue;
		} 
		flag = getTCST(str, tcst);
		if(flag == false)
			continue;
		if(getTCET(str, tcet)==false)
		{
			printf("Error : when looking for TCET\n%s", str);
			continue;
		}
		if(getST(str, st)==false)
		{
			printf("Error : when looking for ST\n%s", str);
			continue;
		}
		if(getET(str, et)==false)
		{
			printf("Error : when looking for ET\n%s", str);
			continue;
		}		
		getCategory(str, category);
		
		getTimeInterval(tcst, tcet, tcrt);
		rt = atof(tcrt)/1000.0;
		stimestamp = (atof(tcst)) / 1000000.0 ;
		etimestamp = (atof(tcet)) / 1000000.0;
		
		//printf("ST=%s ET=%s\nTCST=%s TCET=%s TCRT=%s\nsTime=%.3f,eTime=%.3f,%s,%.3f\n", st, et, tcst, tcet, tcrt, stimestamp, etimestamp, category, rt);
		//printf("Log: %s", str);

		fprintf(fp2,"%s,%.3f,%.3f,%s,%.3f\n", id, stimestamp, etimestamp, category, rt);
		fprintf(fp3,"%.3f,%.3f,%s,%.3f\n", stimestamp, etimestamp, category, rt);
		memset(str, 0, sizeof(str));
	}	

	fclose(fp);
	fclose(fp2);
	fclose(fp3);
	return 0;
}
