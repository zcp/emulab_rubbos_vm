#!/bin/bash

WORKLOAD=$1
WORKLOADTYPE=$2
FILE=$3
INPUTDIR=$4
TARGET=$5

curr_dir=`pwd`


cp $INPUTDIR/QueueLength*.csv .

TEST=$(grep "Test start" $FILE | awk -F ">" '{print $NF}' | awk -F "[- :]" '{print $1"\t" $2"\t" $3"\t" $4"\t" $5"\t" $6}')
read exptotalstyear exptotalstmonth exptotalstday exptotalsthr exptotalstmin exptotalstsec <<< $TEST

TEST=$(grep "Runtime session start" $FILE | awk -F ">" '{print $NF}' | awk -F "[- :]" '{print $1"\t" $2"\t" $3"\t" $4"\t" $5}')
read expbeginyear expbeginmonth expbeginday expbeginhr expbeginmin <<< $TEST
let newexpbeginhr=$expbeginhr+2

TEST=$(grep "Down ramp start" $FILE | awk -F ">" '{print $NF}' | awk -F "[- :]" '{print $1"\t" $2"\t" $3"\t" $4"\t" $5}')
read expendyear expendmonth expendday expendhr expendmin <<< $TEST
let newexpendhr=$expendhr+2

TEST=$(grep "Test end" $FILE | awk -F ">" '{print $NF}' | awk -F "[- :]" '{print $4"\t" $5"\t" $6}')
read exptotalstophr exptotalstopmin exptotalstopsec <<< $TEST

TIMESPAN=$exptotalstyear$exptotalstmonth$exptotalstday$exptotalsthr$exptotalstmin$exptotalstsec"-"$exptotalstophr$exptotalstopmin$exptotalstopsec
EXP_BEGIN=$expbeginyear$expbeginmonth$expbeginday$newexpbeginhr$expbeginmin
EXP_END=$expendyear$expendmonth$expendday$newexpendhr$expendmin

echo $TIMESPAN
echo $EXP_BEGIN
echo $EXP_END
echo $WORKLOAD

#if [ "$WORKLOADTYPE" = "RW" ] ; then
./run.sh $TIMESPAN $EXP_BEGIN $EXP_END $WORKLOAD $WORKLOADTYPE
#else
#    ./run.sh $TIMESPAN $EXP_BEGIN $EXP_END $WORKLOAD $WORKLOADTYPE
#fi

cp ./*$TIMESPAN* $TARGET
rm -f ./*.csv

