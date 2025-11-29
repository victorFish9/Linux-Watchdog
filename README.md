# Linux-Watchdog
self-healing Bash script that monitors system resources (Disk/Memory) and make sure critical services remain active


**Tools**

OS: Kali Linux.

Python3: To run the dummy service.

**Setup Guide**

1. File Placement

Place the files in a working directory /home/kali/project/

2. Configure Paths

Open watchdog.sh and update the START_COMMAND variable to match your actual file path.
My example:

START_COMMAND="nohup python3 /home/kali/project/dummy_service.py > /dev/null 2>&1 &"


3. Permissions

Make the script executable:

chmod +x watchdog.sh


For testing, create the log file in your home folder or change the script's LOG_FILE variable:

touch /var/log/system_health.log
sudo chmod 666 /var/log/system_health.log


How to Test the "Self-Healing"

Step 1: Start the Service

Start the dummy Python service manually:

python3 dummy_service.py &


Note the PID (Process ID).

Step 2: Verify it's running

ps aux | grep dummy_service.py


Step 3: Run the Watchdog (Manual Test)

Run the script manually to see if it detects the running service:

./watchdog.sh
cat /var/log/system_health.log


It should effectively do nothing or log that disk usage is normal.

Step 4: Simulate a Crash

Kill the python process:

pkill -f dummy_service.py


Step 5: Run the Watchdog (Remediation Test)

Run the script again:

./watchdog.sh


Check the logs immediately:

cat /var/log/system_health.log


Expected Output:

[Date] ALERT: dummy_service.py is NOT running.
[Date] ATTEMPT: Restarting dummy_service.py...
[Date] SUCCESS: dummy_service.py was successfully restarted.

Verify the service is back alive:

ps aux | grep dummy_service.py


Automation (Cron Job)

To make this a true "Watchdog," set it to run every minute.

Open Crontab:

crontab -e


Add the following line to the bottom:

* * * * * /home/kali/project/watchdog.sh


Save and exit. The script will now check your system health and service status automatically every 60 seconds.
