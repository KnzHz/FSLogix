# ****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Super charged by KnzHz
# ****************************************************

<#
.SYNOPSIS
Shows a message to user in the notificarion area if FSLogix profile is almost full.
		
.DESCRIPTION
Gets information about the users FSLogix profile (size and remaining size) and calculates the free space in percent.

Layers of Warnings:
There two percentages to think of here, Hard and Soft warning, each has a different message and HARD warnings have an initial Popup box 
and each loop will then be notifications after that. Soft Warning will only be ONCE when the script starts, after initial wait time. 
		
.EXAMPLE
.FSLogix Profile Size Warning.ps1
	    
.NOTES
This script must be run on a machine where the user is currently logged on.
Should be run as a powershell login script via GPO.
#>

#######################################
#Configurable Section START

$firstwarn = 1
#Initial wait time
$Waittimefirst= 1
#Time in seconds between each check
$looptime = 3600
#Percentage of free space on Soft warning
$PercentFreeWarningSoft = 10
#Percentage of free space on Hard warning
$PercentFreeWarningHard = 5

#Configurable Section END
#######################################
#Just for the while loop
$run = 1
#Define first loop
$firstrun = 1
#Define first Hard warning

# add the required .NET assembly
Add-Type -AssemblyName System.Windows.Forms


Start-Sleep $Waittimefirst
while($run -eq 1) {
# Wait 10 sec. till showing the message

# Get the relevant informations from the FSLogix profile
$FSLProfileSize = Get-Volume -FileSystemLabel *Profile-$ENV:USERNAME* | Where-Object { $_.DriveType -eq 'Fixed'}

# Execute only if FSLogix profile is available
IF (!($FSLProfileSize -eq $nul))
{
	# Calculate the free space in percent
	$PercentFree = [Math]::round((($FSLProfileSize.SizeRemaining/$FSLProfileSize.size) * 100))
    $whatsleft = [Math]::round((($FSLProfileSize.SizeRemaining/1024)/1024/1024),1)

	# If free space is less then Hard limit show message
	IF ($PercentFree -le $PercentFreeWarningHard) 
    {
        if($firstwarn -eq 1) 
        {
          [System.Windows.Forms.MessageBox]::Show('You have almost no space left in your profile: ' + $whatsleft + ' GiB.' + "`n`n" + 'Clean out your profile or contact support!','Warning: Almost no Profile diskspace!','OK','Error') 
          $firstwarn = 0 
        } else {
            wlrmdr -s 25 -f 3 -t Warning: Almost no Profile diskspace!  -m You have almost no space left in your profile: $whatsleft GiB. Clean out your profile or contact support!
        }
    }

    # First time we just warn that people are close 
    IF ($PercentFree -le $PercentFreeWarningSoft -and $firstrun -eq 1) 
    {
        wlrmdr -s 25 -f 3 -t Warning: Low on Profile diskspace!  -m You are using most of your diskpace in your profile: $whatsleft GiB. Clean out your profile or contact support!
        $firstrun = 0
    }

}
Start-Sleep $looptime
}
