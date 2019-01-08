#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define InputFileName "CJDBC_response_time.log"
#define OutputFileName "QueueLength-Mysql.csv"
#define OutputFileName2 "DBImport-Mysql.csv"

#define max_line_length 10000
#define max_id_length 20
#define max_timestamp_length 50
#define max_category_length 30
#define max_name_length 1000

#define resource1 "request"

bool getID(char str[], char id[])
{
//	memset(id, 0, sizeof(id));
	memset(id, 0, max_id_length);
	char *ptr = strstr(str, "/*");
	if(ptr==NULL)
		return false;
		
	char tmp[max_id_length];
	memset(tmp, 0, sizeof(tmp));
	sscanf(ptr, "/* %s */", tmp);
	ptr=strstr(tmp, "urlID=");
	if(ptr==NULL)
		strncpy(id, tmp, max_id_length);
	else
		strncpy(id, tmp+6, max_id_length);
	return true;
}

/*
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
*/
bool getTimeStamp(char str[], char timestamp[])
{
	memset(timestamp, 0, sizeof(timestamp));
	char *ptr = strstr(str, "STimeStamp(ms)=");
	if(ptr==NULL)
		return false;
	
	sscanf(ptr, "STimeStamp(ms)=%s ", timestamp);
	
	return true;
}

bool getDBST(char str[], char dbst[])
{
	memset(dbst, 0, sizeof(dbst));
	char *ptr = strstr(str, "DBST(nano)=");
	if(ptr==NULL)
		return false;
	
	sscanf(ptr, "DBST(nano)=%s ", dbst);

	return true;
}

bool getDBET(char str[], char dbet[])
{
	memset(dbet, 0, sizeof(dbet));
	char *ptr = strstr(str, "DBET(nano)=");
	if(ptr==NULL)
		return false;

	sscanf(ptr, "DBET(nano)=%s ", dbet);

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
	char *ptr;
	ptr = strstr(str, "SELECT");
	if(ptr != NULL)
	{
		strncpy(category, "SELECT", max_category_length);
		return true;
	}
	ptr = strstr(str, "INSERT");
	if(ptr != NULL)
	{
		strncpy(category, "INSERT", max_category_length);
		return true;
	}
	ptr=strstr(str, "UPDATE");
	if(ptr != NULL)
	{
		strncpy(category, "UPDATE", max_category_length);
		return true;
	}
	ptr=strstr(str, "DELETE");
	if(ptr != NULL)
	{
		strncpy(category, "DELETE", max_category_length);
		return true;
	}
	strncpy(category, "OTHERS", max_category_length);
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
	//FILE *fp, *fp2, *fp3;
	FILE *fp, *fp2, *fp3;
	char inFileName[max_name_length] = {0};
	if(argc >= 2)
		strncpy(inFileName, argv[1], max_name_length);
	else
		strncpy(inFileName, InputFileName, max_name_length);
	char outFileName[max_name_length] = {0};
	int ptr = 0;
	int count = 0;
	for(ptr = 0; ptr<strlen(inFileName); ++ptr) {
		if(inFileName[ptr] == '_')
			count += 1;
		if(count == 3)
			break;
	}
	ptr += 1;
	strncpy(outFileName, inFileName, ptr);
	strncat(outFileName, resource1, max_name_length);
	strncat(outFileName, ".csv", max_name_length);

	fp = fopen(inFileName, "r");
	fp2 = fopen(outFileName, "w");
	fp3 = fopen(OutputFileName, "a");

/*	if(argc==4)
	{
		fp = fopen(argv[1], "r");
                fp2 = fopen(argv[2], "a");
		fp3 = fopen(argv[3], "a");
        }
        else
        {
                fp = fopen(InputFileName, "r");
                fp2 = fopen(OutputFileName, "a");
		fp3 = fopen(OutputFileName2, "a");
	} */
	char str[max_line_length];
	memset(str, 0, sizeof(str));
	char id[max_id_length];
	char timestamp[max_timestamp_length];
	char dbst[max_timestamp_length];
	char dbet[max_timestamp_length];
	char st[max_timestamp_length];
	char et[max_timestamp_length];
	char dbrt[max_timestamp_length];
	char exet1[max_timestamp_length];
	double rt1, rt2;
	double stimestamp, etimestamp, rt;
	char category[max_category_length];

	while(fgets(str, max_line_length, fp))
	{
		if(getID(str, id)==false)
		{
			printf("Error : when looking for id\n%s", str);
			break;
		}
		if(getTimeStamp(str, timestamp)==false)
		{
			printf("Error : when looking for timestamp\n%s", str);
			break;
		}
		if(getDBST(str, dbst)==false)
		{
			printf("Error : when looking for DBST\n%s", str);
			break;
		}
		if(getDBET(str, dbet)==false)
		{
			printf("Error : when looking for DBET\n%s", str);
			break;
		}
		if(getST(str, st)==false)
		{
			printf("Error : when looking for ST\n%s", str);
			break;
		}
		if(getET(str, et)==false)
		{
			printf("Error : when looking for ET\n%s", str);
			break;
		}		
		getCategory(str, category);
		
		getTimeInterval(st, dbst, exet1);
		getTimeInterval(dbst, dbet, dbrt);
		rt1 = atof(exet1)/1000000.0;
		rt2 = atof(dbrt)/1000000.0;
		stimestamp = (atof(timestamp) + rt1) / 1000.0 ;
		etimestamp = (atof(timestamp) + rt1 + rt2) / 1000.0;
		
		//printf("ID=%s TimeStamp=%s\nST=%s ET=%s\nDBST=%s DBET=%s\nEXET1=%s DBRT=%s\nEXET1=%f EXET2=%f\nsTime=%.3f,eTime=%.3f,,%.3f\n", id, timestamp, st, et, dbst, dbet, exet1, dbrt, rt1, rt2, stimestamp, etimestamp, rt2);
		//printf("Log: %s", str);

		//fprintf(fp2,"%.3f,%.3f,%s,%.3f\n", stimestamp, etimestamp, category, rt2);
		fprintf(fp2,"%s,%.3f,%.3f,%s,%.3f\n", id, stimestamp, etimestamp, category, rt2);
		
		//fprintf(fp3,"%s,%.3f,%.3f,%s,%.3f\n", id, stimestamp, etimestamp, category, rt2);
		fprintf(fp3,"%.3f,%.3f,%s,%.3f\n", stimestamp, etimestamp, category, rt2);
		memset(str, 0, sizeof(str));
	}	

	fclose(fp);
	fclose(fp2);
	fclose(fp3);
	return 0;
}
