#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//#define InputFileName1 "TOMCAT1.log"
#define InputFileName1 "TOMCAT1_access.log"
#define InputFileName2 "TOMCAT1_servlets.log"
#define OutputFileName "QueueLength-mysql.csv"
#define OutputFileName2 "DBImport-mysql.csv"
#define resource1 "_request"

#define max_name_length 1000
#define max_line_length 10000
#define max_id_length 20
#define max_timestamp_length 50
#define max_category_length 30
#define max_table_size 20000000
#define max_db 20

#define id_length 13

typedef struct request{
	char id[max_id_length];
	char timestamp[max_timestamp_length];
	char st[max_timestamp_length];
	char et[max_timestamp_length];
	char category[max_category_length];
}Request;

Request table[max_table_size];

int findTable(int counter, char id[]){

	for(int i = 0; i< counter; i++)
	{
		if(strcmp(table[i].id, id)==0)
			return i;
	}
	return -1;
}

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
	if(id[id_length-1]>='0' && id[id_length-1]<='9')
		id[id_length] = 0;
	else
		id[id_length-1] = 0;
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

bool getTimeStamp(char str[], char timestamp[])
{
	memset(timestamp, 0, sizeof(timestamp));
	char *ptr = strstr(str, "timestamp=");
        //printf("%s\n", ptr);
        //return false;
	if(ptr==NULL)
		return false;
	
	sscanf(ptr, "timestamp=%s ", timestamp);
	//printf("%s\n", ptr);
	return true;
}


bool getST(char str[], char st[])
{
	memset(st, 0, sizeof(st));
	char *ptr = strstr(str, "ST(nano)=");
	if(ptr==NULL)
		return false;
	
	sscanf(ptr, "ST(nano)=%s ", st);

	return true;
}

bool getET(char str[], char et[])
{
	memset(et, 0, sizeof(et));
	char *ptr = strstr(str, "ET(nano)=");
	if(ptr==NULL)
		return false;

	sscanf(ptr, "ET(nano)=%s ", et);
	
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

int getDB(char str[], char dbst[][max_timestamp_length], char dbet[][max_timestamp_length])
{
	int num = 0;
	char *ptr, *ptr2;
	ptr = strstr(str, "DBST(nano)=");
	while(ptr!=NULL)
	{
		sscanf(ptr, "DBST(nano)=%s ", dbst[num]);
		ptr2 = strstr(str, "DBET(nano)=");
		sscanf(ptr2, "DBET(nano)=%s ", dbet[num]);
		num += 1;
		str = ptr2 + 1;
		ptr = strstr(str, "DBST(nano)=");
	}	
	return num;
}

//void dealOutput(int location, char dbst[][max_timestamp_length], char dbet[][max_timestamp_length], int dbcounter, FILE *fp, FILE *fp1)
void dealOutput(int location, char dbst[][max_timestamp_length], char dbet[][max_timestamp_length], int dbcounter, FILE *fp)
{
	char exet[max_timestamp_length];
	char rt[max_timestamp_length];
	double stimestamp, etimestamp, rt1, exet1, timestamp;	

	for(int i=0; i<dbcounter; i++)
	{
		getTimeInterval(dbst[i], dbet[i], rt);
		getTimeInterval(table[location].st, dbst[i], exet);
		exet1 = atof(exet) / 1000000.0;
		rt1 = atof(rt) / 1000000.0;
		timestamp = atof(table[location].timestamp);
                //printf ("timestamp:%s\t location:%d\n", table[location].timestamp, location);
		stimestamp = (timestamp + exet1)/1000.0;
		etimestamp = (timestamp + exet1 + rt1)/1000.0;
                //printf("%f,%f,%f\n", timestamp,stimestamp,etimestamp);
                //return;
		//fprintf(fp, "%.3f,%.3f,%s,%.3f\n", stimestamp, etimestamp, table[location].category, rt1);
		//:printf("%s,%.3f,%.3f,%s,%.3f\n", table[location].id, stimestamp, etimestamp, table[location].category, rt1);
		
		fprintf(fp, "%s,%.3f,%.3f,%s,%.3f\n", table[location].id, stimestamp, etimestamp, table[location].category, rt1);
		//fprintf(fp1, "%s,%.3f,%.3f,%s,%.3f\n", table[location].id, stimestamp, etimestamp, table[location].category, rt1);
	}	
}

int main(int argc, char *argv[])
{
	//FILE *fp, *fp1, *fp2, *fp3;
	FILE *fp, *fp1, *fp2;
	char inFileName1[max_name_length] = {0};
	char inFileName2[max_name_length] = {0};
	if(argc >= 2) 
		strncpy(inFileName1, argv[1], max_name_length);
	else
		strncpy(inFileName1, InputFileName1, max_name_length);
	if(argc >= 3)
		strncpy(inFileName2, argv[2], max_name_length);
	else
		strncpy(inFileName2, InputFileName2, max_name_length);
	char outFileName[max_name_length] = {0};
	int ptr = 0;
	int count = 0;
	for(ptr = 0; ptr<strlen(inFileName1); ++ptr) {
		if(inFileName1[ptr] == '_')
			count += 1;
		if(count == 3)
			break;
	}
	ptr += 1;
	strncpy(outFileName, inFileName1, ptr);	
	strncat(outFileName, resource1, max_name_length);
	strncat(outFileName, ".csv", max_name_length);

	fp = fopen(inFileName1, "r");
	fp1 = fopen(inFileName2, "r");
	fp2 = fopen(outFileName, "a");


/*	if(argc==5)
	{
		fp = fopen(argv[1], "r");
		fp1 = fopen(argv[2], "r");
		fp2 = fopen(argv[3], "a");
		fp3 = fopen(argv[4], "a");
	}
	else
	{
		fp = fopen(InputFileName1, "r");
		fp1 = fopen(InputFileName2, "r");
		fp2 = fopen(OutputFileName, "a");
		fp3 = fopen(OutputFileName2, "a");
	}
*/
	char str[max_line_length];
	memset(str, 0, sizeof(str));
	char timestamp[max_timestamp_length];
	char id[max_id_length];
	char dbst[max_db][max_timestamp_length];
	char dbet[max_db][max_timestamp_length];
	double stimestamp, etimestamp, rt;
	char category[max_category_length];

	int counter = 0;
	int dbcounter = 0;

	while(fgets(str, max_line_length, fp))
	{
		if(getID(str, table[counter].id)==false)
		{
			printf("Error : when looking for id\n%s", str);
			break;
		}
		if(getTimeStamp(str, table[counter].timestamp)==false)
		{
			printf("Error : when looking for timestamp\n%s", str);
			break;
		}
		if(getST(str, table[counter].st)==false)
		{
			printf("Error : when looking for ST\n%s", str);
			break;
		}
		if(getET(str, table[counter].et)==false)
		{
			printf("Error : when looking for ET\n%s", str);
			break;
		}		
		getCategory(str, table[counter].category);
		memset(str, 0, sizeof(str));
		counter += 1;
	}
	printf("COUNTER = %d\n", counter);
	fclose(fp);
	while(fgets(str, max_line_length, fp1))
	{
		if(getID(str, id)==false)
		{
			printf("Error : when looking for id\n%s", str);
			break;
		}
		dbcounter = getDB(str, dbst, dbet);
		if(dbcounter < 0)
		{
			printf("Error : when looking for db connection\n%s", str);
			break;
		}
		int location = findTable(counter, id);
		if(location < 0)
		{
			printf("Error : when looking for id at table\n%s", str);
			break;
		}
//		dealOutput(location, dbst, dbet, dbcounter, fp2, fp3);
		dealOutput(location, dbst, dbet, dbcounter, fp2);
		//printf("%s %s\n", table[location].id, id);	
		//for(int i=0; i<dbcounter; i++)
		//	printf("DBST=%s DBET=%s ",dbst[i], dbet[i]);
		//printf("\n%s\n", str);		

		//fprintf(fp2,"%.3f,%.3f,%s,%.3f\n", stimestamp, etimestamp, category, rt);
		memset(str, 0, sizeof(str));
	}	

	fclose(fp1);
	fclose(fp2);
//	fclose(fp3);
	return 0;
}
