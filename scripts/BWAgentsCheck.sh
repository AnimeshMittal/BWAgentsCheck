#!/bin/sh
#
#
Date=`date "+%d-%m-%Y_%H-%M-%S"`

SCR_HOME=[[[ScriptHomeDirectory]]]
SCR=$SCR_HOME/scripts
LOGS=$SCR_HOME/logs
INPUT=$SCR_HOME/input
DATA=$INPUT/data
TMP=$INPUT/tmp
EMAIL_TEMP=$INPUT/EmailTemplates

LogFile=$LOGS/BWAgentsCheck_"$Date".log
exec >> $LogFile 2>&1

TO="To@domain.com"
CC="CC@domain.com"
FROM="BWAgentsCheck@noreply.com"

echo "----------------------------$(date '+[%d/%m/%Y %H:%M:%S]') - Script initiated.---------------------------"

cat "$EMAIL_TEMP"/start.html > "$INPUT"/email.html

if [ -f "$TMP"/agent_info.tx ]
then
	rm -rf "$TMP"/agent_info.txt

elif [ -f "$TMP"/RunningAgents.txt ]
then
	rm -rf "$TMP"/RunningAgents.txt

elif [ -f "$TMP"/UnreachableAgents.txt ]
then
	rm -rf "$TMP"/UnreachableAgents.txt

else
	echo "$(date '+[%d/%m/%Y %H:%M:%S]')- $TMP is empty at the begining of the script execution."
fi

for ENV in Unsecured Secured1 Secured2
do
	for line in `cat $DATA/agents_$ENV.lst`
	do
		Host=`echo "${line}" | awk 'BEGIN {FS ="."} {print $1}'`
		Port=`echo "${line}" | awk 'BEGIN {FS =":"} {print $2}' | sed 's/\,.*//'`
		Inst=`echo "${line}" | awk 'BEGIN {FS =","} {print $2}'`
		TibEnv=`echo "${line}" | awk 'BEGIN {FS =","} {print $3}'`
		agent=`echo "${line}" | awk 'BEGIN {FS =","} {print $1}'`

		if [ "$ENV" = 'Unsecured' ]
		then
			curl -m 20 -s http://"$agent"/bw/v1/agents/info > "$TMP"/agent_info.txt
		else
			USER=`cat $DATA/creds_$ENV | awk 'BEGIN {FS =","} {print $1}'`
			PASS=`cat $DATA/creds_$ENV | awk 'BEGIN {FS =","} {print $2}'`
			curl -m 20 -s https://"$USER":"$PASS"@"$agent"/bw/v1/agents/info > "$TMP"/agent_info.txt
		fi

		while IFS=',' read -ra Info
		do
			for i in "${Info[@]}"
			do
				echo $i >> "$TMP"/info_"$Host"_"$Port".txt
			done
		done <<< `cat "$TMP"/agent_info.txt`

		if [ -s "$TMP"/info_"$Host"_"$Port".txt ]
		then
			State=`grep -i "state" "$TMP"/info_"$Host"_"$Port".txt | grep -v "config" | awk 'BEGIN {FS =":"} {print $2}' | sed -e "s/\"//g"`
			if [ "$State" = 'Running' ]
			then
				echo "$line" >> "$TMP"/RunningAgents.txt
			else
				echo "$line" >> "$TMP"/UnreachableAgents.txt
				sed -e 's/ServerName/'"$Host"'/g' -e 's/BWInst/'"$Inst"'/g' -e 's/Environ/'"$TibEnv"'/g'  -e 's/Status/'"$State"'/g' $EMAIL_TEMP/dynamic.html >> "$INPUT"/email.html
			fi
		else
			echo "$line" >> "$TMP"/UnreachableAgents.txt
			sed -e 's/ServerName/'"$Host"'/g' -e 's/BWInst/'"$Inst"'/g' -e 's/Environ/'"$TibEnv"'/g' -e 's/Status/Unreachable/g' $EMAIL_TEMP/dynamic.html >> "$INPUT"/email.html
		fi

		rm -rf "$TMP"/info_"$Host"_"$Port".txt

	done
done

echo -en "$(date '+[%d/%m/%Y %H:%M:%S]')- BW Agents that are in Running State:\n\n"
cat "$TMP"/RunningAgents.txt
echo -en "\n\n\n\n"
echo -en "$(date '+[%d/%m/%Y %H:%M:%S]')- BW Agents that are in Unreachable State:\n\n"
cat "$TMP"/UnreachableAgents.txt

cat $EMAIL_TEMP/end.html >> "$INPUT"/email.html

Subject="[Alert]BW Agents Unreachable Status"
Body="`cat $INPUT/email.html`"

if [ -s "$TMP"/UnreachableAgents.txt ]
then
	$SCR/SendMail_BWAgent.sh "$TO" "$CC" "$FROM" "$Subject" "$Body"
else
	echo -en "$(date '+[%d/%m/%Y %H:%M:%S]') All BW Agents are in Running state. None of them is Unreachable.\n\n"
fi

rm -rf "$TMP"/UnreachableAgents.txt "$TMP"/RunningAgents.txt "$TMP"/agent_info.txt

echo -en "\n\n$(date '+[%d/%m/%Y %H:%M:%S]') - Script execution completed. Exiting the script..."
echo "-------------------------------------------------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------------------------------------------------"
exit
