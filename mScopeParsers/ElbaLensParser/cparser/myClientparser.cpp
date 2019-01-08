#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CLIENTPREFIX "trace_client"
#define APACHEPREFIX "QueueLength-Apache"

#define APACHETOTAL "QueueLength-Apache.csv"
#define DBIMPORT "DBImport-Apache.csv"

#define max_line_length 10000
#define max_id_length 20
#define max_timestamp_length 50
#define max_category_length 30

#define id_length 16

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
	char *ptr = strstr(str, "STimeStamp(ms)");
	if(ptr==NULL)
		return false;
	
	sscanf(ptr, "STimeStamp(ms)%s ", timestamp);
	
	return true;
}

bool getST(char str[], char st[])
{
	memset(st, 0, sizeof(st));
	char *ptr = strstr(str, "GetConST(nano)=");
	if(ptr==NULL)
		return false;
	
	sscanf(ptr, "GetConST(nano)=%s ", st);

	return true;
}

bool getET(char str[], char et[])
{
	memset(et, 0, sizeof(et));
	char *ptr = strstr(str, " ET(nano)=");
//	char *ptr = strstr(str, " CloseCon(nano)=");
	if(ptr==NULL)
		return false;

	sscanf(ptr, " ET(nano)=%s ", et);
//	sscanf(ptr, " CloseCon(nano)=%s ", et);
	
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

bool checkRequest(char str[])
{
	char *ptr = strstr(str, "Request :");	
	if(ptr != str)
		return false;
	return true;
}

void parseFile(FILE *fpin, FILE *fpout, FILE *fpout2)
{
	char str[max_line_length];
	memset(str, 0, sizeof(str));
	char timestamp[max_timestamp_length];
	char st[max_timestamp_length];
	char et[max_timestamp_length];
	char exet1[max_timestamp_length];
	double stimestamp, etimestamp, rt;
	char category[max_category_length];
	char id[max_id_length];

	while(fgets(str, max_line_length, fpin))
	{
		if(checkRequest(str) == false)
			continue;
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
		if(getST(str, st)==false)
		{
			printf("Error : when looking for DBST\n%s", str);
			break;
		}
		if(getET(str, et)==false)
		{
			printf("Error : when looking for ET\n%s", str);
			break;
		}		
		getCategory(str, category);
		
		getTimeInterval(st, et, exet1);
		rt = atof(exet1)/1000000.0;
		stimestamp = (atof(timestamp)) / 1000.0 ;
		etimestamp = (atof(timestamp) + rt) / 1000.0;
		
		//printf("TimeStamp=%s\nST=%s ET=%s\nEXET1=%s\nsTime=%.3f,eTime=%.3f,%s,%.3f\n", timestamp, st, et, exet1, stimestamp, etimestamp, category, rt);
		//printf("Log: %s", str);

		fprintf(fpout,"%.3f,%.3f,%s,%.3f\n", stimestamp, etimestamp, category, rt);
        fprintf(fpout2,"%s,%.3f,%.3f,%s,%.3f\n", id, stimestamp, etimestamp, category, rt);
		memset(str, 0, sizeof(str));
	}	
}

void parseFile(FILE *fpin, FILE *fpout, FILE *fpout1, FILE *fpout2)
{
    char str[max_line_length];
    memset(str, 0, sizeof(str));
    char timestamp[max_timestamp_length];
    char st[max_timestamp_length];
    char et[max_timestamp_length];
    char exet1[max_timestamp_length];
    double stimestamp, etimestamp, rt;
    char category[max_category_length];
    char id[max_id_length];

    while(fgets(str, max_line_length, fpin))
    {
        if(checkRequest(str) == false)
            continue;
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
        if(getST(str, st)==false)
        {
            printf("Error : when looking for DBST\n%s", str);
            break;
        }
        if(getET(str, et)==false)
        {
            printf("Error : when looking for ET\n%s", str);
            break;
        }
        getCategory(str, category);

        getTimeInterval(st, et, exet1);
        rt = atof(exet1)/1000000.0;
        stimestamp = (atof(timestamp)) / 1000.0 ;
        etimestamp = (atof(timestamp) + rt) / 1000.0;


        fprintf(fpout,"%.3f,%.3f,%s,%.3f\n", stimestamp, etimestamp, category, rt);
        fprintf(fpout1,"%.3f,%.3f,%s,%.3f\n", stimestamp, etimestamp, category, rt);
        fprintf(fpout2,"%s,%.3f,%.3f,%s,%.3f\n", id, stimestamp, etimestamp, category, rt);
        memset(str, 0, sizeof(str));
    }
}


int main(int argc, char* argv[])
{
    int clientcnt = 0;
    int apachecnt = 0;
    clientcnt = atoi(argv[1]);
    apachecnt = atoi(argv[2]);
    if(argc != 3)
    {
        printf("Usage: %s <number of client> <number of apache>\n",argv[0]);
        return -1;
    }
    int i = 0;
    int j = 0;
    int mapping = clientcnt/apachecnt;
    char apachefile[18];
    char clientfile[23];
    FILE *fpin, *fpout, *fpout1, *fpout2;
    fpout = fopen(APACHETOTAL, "w");
    fpout2 = fopen(DBIMPORT, "w");
    for(i =0; i < apachecnt; i++){
        j = i*mapping;
        sprintf(apachefile, "QueueLength-Apache%d.csv", i);
        fpout1 = fopen(apachefile, "w");

        sprintf(clientfile, "client.log");
        fpin = fopen(clientfile, "r");
        parseFile(fpin, fpout, fpout1, fpout2);
        fclose(fpin);

    }

	fclose(fpout);
    fclose(fpout2);
	return 0;
}
