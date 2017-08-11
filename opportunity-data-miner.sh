#!/bin/bash
WORKDIR="/srv/Ticket-analytics/"
echo $REMOVE
echo $ADD
TIMESTAMP=200001
TIMESTAMP=$(date --date='20 minute ago' +"%d-%m-%Y")
TASKS=tasks
TASKFILE=tasks-file.txt
BILLEDFILE=billed-file.txt  
echo $TIMESTAMP


###### getting export #####
curl -u login@email.com:yourpass -O oportunity.csv "http://your-website.com/products/crm/deals.aspx?action=export" --output $FILENAME$TIMESTAMP.csv


###### cutting csv ( you need csvkit ) #####
csvcut -c 1,16,17,11,19,20,10 $FILENAME$TIMESTAMP.csv > $FILENAME$TIMESTAMP$TASKS.csv


INPUT=$FILENAME$TIMESTAMP$TASKS.csv
IFS=","
echo "Loaded File"
rm $TASKFILE
rm $BILLEDFILE 
echo "---------- Billed ----------" >> $WORKDIR$BILLEDFILE

while read A B C D E F G
do


TITLE="$(echo "$A"| sed -e 's/^"//' -e 's/"$//')"
OUR_PRIORITY="$(echo "$B"| sed -e 's/^"//' -e 's/"$//')"
HQ_PRIORITY="$(echo "$C"| sed -e 's/^"//' -e 's/"$//')"
STAGE="$(echo "$D"| sed -e 's/^"//' -e 's/"$//')"
FIRST_ID="$(echo "$E"| sed -e 's/^"//' -e 's/"$//')"
SECOND_ID="$(echo "$F"| sed -e 's/^"//' -e 's/"$//')"
OWNER="$(echo "$G"| sed -e 's/^"//' -e 's/"$//')"
STAGE1=Billed
STAGE2=Cancelled
STAGE3=Denied
HIGH=1

if [[ $STAGE == *"$STAGE1"* ]];
      then
            echo "$TITLE | Stage: $STAGE | Priority: $OUR_PRIORITY | Owner: $OWNER " >> $WORKDIR$TASKFILE
        
      else
      if [[ $STAGE == *"$STAGE2"* ]];
      	then
      		echo "Cancelled"
      	else
      	if [[ $STAGE == *"$STAGE3"* ]];
      		then
      		echo "Denied"
      		else

      		if [[ $OUR_PRIORITY == 1 ]];
            then
                              echo "$TITLE | Stage: $STAGE | Priority: $OUR_PRIORITY | Owner: $OWNER " >> $WORKDIR$TASKFILE
                        
             else
             	if [[ $SA_PRIORITY == 1 ]];
                  then
                              echo "$TITLE | Stage: $STAGE | Priority: $OUR_PRIORITY | Owner: $OWNER " >> $WORKDIR$TASKFILE
                fi
  
      		fi
      		fi
      	fi
fi







done < $INPUT


export SUBJECT="Opportunities report from day $TIMESTAMP"
export EMAIL1=recivermail1@gmail.com
export EMAIL2=recivermail2@gmail.com
cat $WORKDIR$BILLEDFILE >> $WORKDIR$TASKFILE
cat $WORKDIR$TASKFILE | mail -s "$SUBJECT" -a $WORKDIR$FILENAME$TIMESTAMP".csv"  -r sendermail@gmail.com  "$EMAIL1" "$EMAIL2"
