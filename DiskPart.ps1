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

  [Parameter(
    Mandatory,
    HelpMessage="Specifies the file system with which to format the volume. The acceptable values for this parameter are:NTFS, ReFS, exFAT, FAT32, and FAT."
  )]
  [ValidateSet("FAT", "FAT32", "exFAT", "NTFS", "ReFS")]
  [Alias("FS")]
  [string]$P_FileSystem,

  [Parameter(
    Mandatory,
    HelpMessage="Specifies a new label to use for the volume."
  )]
  [Alias("FSL")]
  [string]$P_FileSystemLabel
)

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DiskPart() {
  # Sleep time.
  [int]$sleep = 10

  # New line separator.
  $NL = [Environment]::NewLine

  # Run.
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
  Start-Sleep -s $sleep
}

# Clear disk.
function Start-DPDiskClear() {
  Write-DPMsg -Title -Message "--- [DISK $($P_DiskNumber)] Clear Disk..."

  Write-Warning "You specified drive number '$($P_DiskNumber)' and drive letter '$($P_DriveLetter)'. All data will be DELETED." -WarningAction Inquire
  Clear-Disk -Number $P_DiskNumber -RemoveData -RemoveOEM -Confirm:$false
  Show-DPDiskList
  Start-Sleep -s $sleep
}

# Initialize disk.
function Start-DPDiskInit() {
  Write-DPMsg -Title -Message "--- [DISK $($P_DiskNumber)] Initialize Disk..."

  Initialize-Disk -Number $P_DiskNumber -PartitionStyle "GPT"
  Show-DPDiskList
  Start-Sleep -s $sleep
}

# Create partition.
function Start-DPDiskPartition() {
  Write-DPMsg -Title -Message "--- [DISK $($P_DiskNumber)] Create Partition..."

  New-Partition -DiskNumber $P_DiskNumber -UseMaximumSize -DriveLetter "$($P_DriveLetter)"
  Start-Sleep -s $sleep
}

# Format disk volume.
function Start-DPDiskFormat() {
  Write-DPMsg -Title -Message "--- [DISK $($P_DiskNumber)] Format Disk Volume ($($P_DriveLetter) / $($P_FileSystem))..."

  Format-Volume -DriveLetter "$($P_DriveLetter)" -FileSystem "$($P_FileSystem)" -Force -NewFileSystemLabel "$($P_FileSystemLabel)"
  Show-DPVolumeList
  Start-Sleep -s $sleep
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

function Write-DPMsg() {
  param (
    [string]$Message,
    [switch]$Title = $false
  )

  if ( $Title ) {
    Write-Host "$($NL)$($Message)" -ForegroundColor Blue
  } else {
    Write-Host "$($Message)"
  }
}

function Show-DPDiskList() {
  Write-DPMsg -Title -Message "--- [DISK $($P_DiskNumber)] Disk List..."
  Get-Disk
}

function Show-DPVolumeList() {
  Write-DPMsg -Title -Message "--- [DISK $($P_DiskNumber)] Volume List..."
  Get-Volume
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< INIT FUNCTIONS >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-DiskPart
