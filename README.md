# BWAgentsCheck
Monitor, Identify, and Notify Unreachable TIBCO BW 6.X Agents.

Objective: This Scripted Solution is meant to automate the process of Monitoring, Identifying, and Notifying Unreachable TIBCO BW 6.X Agents.

Usage Methodology: It can be used manually at any time in the environment on-demand or can be scheduled to run periodically through Cron, Control-M, or any other Remote Execution and Scheduling Tool.

Input Files: User/Admin of the script has to create input files and API credential files(only if BW Agent API calls are secured) in advance listing technical information about BW Agents that have to be monitored.

                1. Go to the path- [[[ScriptHomeDirectory]]]/input/data/
                2. Change the content of Agent files and Creds files. The format for the content of these files is self-explanatory.
                3. Note- Do not change the format for the content or names of these files.

Changes Required in Scripts: Few changes are required in scripts to make the solution compatible with, and aware of the environment/server on which it has to run.

                1. Go to the path where you have placed the scripted solution.
                2. Further, go to the path- BWAgentsCheck/scripts/
                3. Open script BWAgentsCheck.sh
                4. Change [[[ScriptHomeDirectory]]] with relevant script home path.
                5. Change Email IDs for receiving proper email notifications.
                6. Save and Close script BWAgentsCheck.sh
                7. Open script SendMail_BWAgent.sh
                8. Change [[[ScriptHomeDirectory]]] with relevant script home path.
                9. Save and Close script SendMail_BWAgent.sh

Usage Command: As it is a Unix Shell scripted solution, kindly use the below command to trigger it.

                1. Go to the path- [[[ScriptHomeDirectory]]]
                2. Run the Command- /bin/sh ./BWAgentsCheck.sh

Mandatory Requirements: Availability of properly functioning 'Curl', 'SendMail', and 'SMTP Email' services on the server on which this scripted solution needs to run.
