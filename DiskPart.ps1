<#
.SYNOPSIS
.DESCRIPTION
#>

#Requires -Version 7.2
#Requires -RunAsAdministrator

Param(
  [Parameter(
    Mandatory,
    HelpMessage="Specifies an array of disk numbers."
  )]
  [ValidatePattern("^[0-9]+$")]
  [Alias("DN")]
  [int]$P_DiskNumber,

  [Parameter(
    Mandatory,
    HelpMessage="Specifies the specific drive letter to assign to the new partition."
  )]
  [ValidatePattern("^[A-Z]$")]
  [Alias("DL")]
  [string]$P_DriveLetter,

  [Parameter(HelpMessage="Specifies the file system with which to format the volume. The acceptable values for this parameter are:NTFS, ReFS, exFAT, FAT32, and FAT.")]
  [ValidateSet("FAT", "FAT32", "exFAT", "NTFS", "ReFS")]
  [Alias("FS")]
  [string]$P_FileSystem = "NTFS",

  [Parameter(
    Mandatory,
    HelpMessage="Specifies a new label to use for the volume."
  )]
  [Alias("FSL")]
  [string]$P_FileSystemLabel
)

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

# Sleep time.
[int]$SLEEP = 10

# New line separator.
$NL = [Environment]::NewLine

# Load functions.
. "$($PSScriptRoot)\DiskPart.Functions.ps1"

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DiskPart() {
  Start-DPDiskList
  Start-DPDiskClear
  Start-DPDiskInit
  Start-DPDiskPartition
  Start-DPDiskFormat
}

# -------------------------------------------------------------------------------------------------------------------- #
# DISK PARTITION.
# -------------------------------------------------------------------------------------------------------------------- #

# Disk list.
function Start-DPDiskList() {
  Show-DPDiskList
  Start-Sleep -s $SLEEP
}

# Clear disk.
function Start-DPDiskClear() {
  Write-DPMsg -T "HL" -M "[DISK $($P_DiskNumber)] Clear Disk..."

  Write-DPMsg -T "W" -A "Inquire" -M "You specified drive number '$($P_DiskNumber)' and drive letter '$($P_DriveLetter)'. All data will be DELETED."
  Clear-Disk -Number $P_DiskNumber -RemoveData -RemoveOEM -Confirm:$false
  Show-DPDiskList
  Start-Sleep -s $SLEEP
}

# Initialize disk.
function Start-DPDiskInit() {
  Write-DPMsg -T "HL" -M "[DISK $($P_DiskNumber)] Initialize Disk..."

  Initialize-Disk -Number $P_DiskNumber -PartitionStyle "GPT"
  Show-DPDiskList
  Start-Sleep -s $SLEEP
}

# Create partition.
function Start-DPDiskPartition() {
  Write-DPMsg -T "HL" -M "[DISK $($P_DiskNumber)] Create Partition..."

  New-Partition -DiskNumber $P_DiskNumber -UseMaximumSize -DriveLetter "$($P_DriveLetter)"
  Start-Sleep -s $SLEEP
}

# Format disk volume.
function Start-DPDiskFormat() {
  Write-DPMsg -T "HL" -M "[DISK $($P_DiskNumber)] Format Disk Volume ($($P_DriveLetter) / $($P_FileSystem))..."

  Format-Volume -DriveLetter "$($P_DriveLetter)" -FileSystem "$($P_FileSystem)" -Force -NewFileSystemLabel "$($P_FileSystemLabel)"
  Show-DPVolumeList
  Start-Sleep -s $SLEEP
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< INIT FUNCTIONS >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-DiskPart
