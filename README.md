# openrctbackup - backup script for your OpenRCT2 server (1.0)
Creates a hot backup of your OpenRCT2 installation and optionally copies it to a offsite server.


---

1. Make sure ssh-keygen is installed: "apt install ssh-keygen"
2. Run "ssh-keygen" and when asked for the password just press enter twice
3. Run "ssh-copy-id -i ~/.ssh/id_rsa.pub your-destination-server" - This will ask you for your remote password. This is normal.
4. Edit the settings at the top of openrctbackup.pl if needed
5. After the first run edit the ~/.rctbackuprc and change your settings if you want to use the offsite backup feature. The next run it should save to your remote host.
6. create a cron job like this:

        1 1 * * * /home/openrct-user/OpenRCT2_Backup/openrctbackup.pl > /dev/null 2>&1

7. This will back up your OpenRCT2 server installation at 1:01am each day, and keep the last 5 backups.

