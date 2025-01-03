#!/usr/bin/perl

# Set these for your situation
my $OPENRCTDIR = "/home/openrct-user/OpenRCT2";
my $BACKUPDIR = "/home/openrct-user/backups";
my $TARCMD = "/bin/tar czf";
my $VERSION = "1.0";

# Init file data
my $MySettings = "$ENV{'HOME'}/.rctbackuprc";
my $BACKUPUSER = "";
my $BACKUPPASS = "";
my $BACKUPSERVER = "";
my $BACKUPPATH = "";
my $DEBUG_MODE = "off";
my $FILEEDITOR = $ENV{EDITOR};
my $DOSNAPSHOT = 0;

#-------------------
# No changes below here...
#-------------------

if ($FILEEDITOR eq "")
{
        $FILEEDITOR = "/usr/bin/nano";
}

# Get if they said a option
my $CMDOPTION = shift;

sub ReadConfigFile
{
	# Check for config file
	if (-f $MySettings)
	{
		# Read in settings
		open (my $FH, "<", $MySettings) or die "Could not read default file '$MySettings' $!";
		while (<$FH>)
		{
			chop();
			my ($Command, $Setting) = split(/=/, $_);
			if ($Command eq "backupuser")
			{
				$BACKUPUSER = $Setting;
			}
			if ($Command eq "backuppass")
			{
				$BACKUPPASS = $Setting;
			}
			if ($Command eq "backupserver")
			{
				$BACKUPSERVER = $Setting;
			}
			if ($Command eq "backuppath")
			{
				$BACKUPPATH = $Setting;
			}
			if ($Command eq "debugmode")
			{
				$DEBUG_MODE = $Setting;
			}
		}
		close($FH);
	}
	else
	{
		# Store defaults
		open (my $FH, ">", $MySettings) or die "Could not create default file '$MySettings' $!";
		print $FH "backupuser=\n";
		print $FH "backuppass=\n";
		print $FH "backupserver=\n";
		print $FH "backuppath=\n";
		print $FH "debugmode=off\n";
		close($FH);
	}
}

sub PrintDebugCommand
{
	if ($DEBUG_MODE eq "off")
	{
		return;
	}
	my $PassedString = shift;
	print "About to run:\n$PassedString\n";
	print "Press Enter To Run This:";
	my $entered = <STDIN>;
}

if ((defined $CMDOPTION) && ($CMDOPTION eq "-snapshot"))
{
        $DOSNAPSHOT = -1;
}

ReadConfigFile();

print "OpenRCTBackup - back up your OpenRTC2 server - version $VERSION\n";
print "==============================================================\n";
if ($DOSNAPSHOT == -1)
{
        print "Running Manual Snapshot\n";
}

if (defined $CMDOPTION)
{
        if ($CMDOPTION ne "-snapshot")
        {
                print "Unknown command line option: '$CMDOPTION'\nOnly allowed option is '-snapshot'\n";
                exit 0;
        }
}

sub SnapShotFunc
{
        print "Backing up OpenRCT2 files: ";
        if (-f "$BACKUPDIR/snapshot.tgz")
        {
                unlink("$BACKUPDIR/snapshot.tgz");
        }
        system("$TARCMD $BACKUPDIR/snapshot.tgz $OPENRCTDIR > /dev/null 2>\&1");
        print "\nBackup Completed.\n";
}

if ($DOSNAPSHOT == -1)
{
        SnapShotFunc();
        exit 0;
}

if (! -d $BACKUPDIR)
{
	print "Backup dir $BACKUPDIR not found, creating...\n";
	system("mkdir -p $BACKUPDIR");
}
print "Moving existing backups: ";

if (-f "$BACKUPDIR/openrctbackup-5.tgz")
{
	unlink("$BACKUPDIR/openrctbackup-5.tgz")  or warn "Could not unlink $BACKUPDIR/openrctbackup-5.tgz: $!";
}
if (-f "$BACKUPDIR/openrctbackup-4.tgz")
{
	rename("$BACKUPDIR/openrctbackup-4.tgz", "$BACKUPDIR/openrctbackup-5.tgz");
}
if (-f "$BACKUPDIR/openrctbackup-3.tgz")
{
	rename("$BACKUPDIR/openrctbackup-3.tgz", "$BACKUPDIR/openrctbackup-4.tgz");
}
if (-f "$BACKUPDIR/openrctbackup-2.tgz")
{
	rename("$BACKUPDIR/openrctbackup-2.tgz", "$BACKUPDIR/openrctbackup-3.tgz");
}
if (-f "$BACKUPDIR/openrctbackup-1.tgz")
{
	rename("$BACKUPDIR/openrctbackup-1.tgz", "$BACKUPDIR/openrctbackup-2.tgz");
}
print "Done\nCreating Backup: ";
system("$TARCMD $BACKUPDIR/openrctbackup-1.tgz --exclude='/sbbs/ctrl/localspy*.sock' --exclude='/sbbs/ctrl/status.sock' $OPENRCTDIR");
if ($BACKUPSERVER ne "")
{
	print "Offsite backup requested\n";
	print "Copying $BACKUPDIR/openrctbackup-1.tgz to $BACKUPSERVER:$BACKUPPORT\n";
	PrintDebugCommand("rsync -avz -e ssh $BACKUPDIR/openrctbackup-1.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH\n");
	system ("rsync -avz -e ssh $BACKUPDIR/openrctbackup-1.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH");
}

print("Done!\n");
exit 0;
