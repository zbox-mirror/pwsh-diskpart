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
  [int]$DiskNumber,

  [Parameter(
    Mandatory,
    HelpMessage="Specifies the specific drive letter to assign to the new partition."
  )]
  [ValidatePattern("^[A-Z]$")]
  [Alias("DL")]
  [string]$DriveLetter,

  [Parameter(
    Mandatory,
    HelpMessage="Specifies the file system with which to format the volume. The acceptable values for this parameter are:NTFS, ReFS, exFAT, FAT32, and FAT."
  )]
  [ValidateSet("FAT", "FAT32", "exFAT", "NTFS", "ReFS")]
  [Alias("FS")]
  [string]$FileSystem,

  [Parameter(
    Mandatory,
    HelpMessage="Specifies a new label to use for the volume."
  )]
  [Alias("FSL")]
  [string]$FileSystemLabel
)

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DiskPart() {
  # Sleep time.
  [int]$sleep = 10

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

function Start-DPDiskList() {
  Show-DPDiskList
  [string]$confirmation = Read-Host -Prompt "You specified drive $($DiskNumber). Continue? (Enter [Y] to continue)"
  Start-Sleep -s $sleep
  if ( ! ( $confirmation -match "[yY]" ) ) { exit }
}

# Clear disk.
function Start-DPDiskClear() {
  Write-DPMsg -Title -Message "--- [DISK $($DiskNumber)] Clear Disk..."
  Clear-Disk -Number $DiskNumber -RemoveData -RemoveOEM -Confirm:$false
  Show-DPDiskList
  Start-Sleep -s $sleep
}

# Initialize disk.
function Start-DPDiskInit() {
  Write-DPMsg -Title -Message "--- [DISK $($DiskNumber)] Initialize Disk..."
  Initialize-Disk -Number $DiskNumber -PartitionStyle "GPT"
  Show-DPDiskList
  Start-Sleep -s $sleep
}

# Create partition.
function Start-DPDiskPartition() {
  Write-DPMsg -Title -Message "--- [DISK $($DiskNumber)] Create Partition..."
  New-Partition -DiskNumber $DiskNumber -UseMaximumSize -DriveLetter "$($DriveLetter)"
  Start-Sleep -s $sleep
}

# Format disk volume.
function Start-DPDiskFormat() {
  Write-DPMsg -Title -Message "--- [DISK $($DiskNumber)] Format Disk Volume ($($DriveLetter) / $($FileSystem))..."
  Format-Volume -DriveLetter "$($DriveLetter)" -FileSystem "$($FileSystem)" -Force -NewFileSystemLabel "$($FileSystemLabel)"
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
    Write-Host "$($Message)" -ForegroundColor Blue
  } else {
    Write-Host "$($Message)"
  }
}

function Show-DPDiskList() {
  Write-DPMsg -Title -Message "--- Disk List..."
  Get-Disk
}

function Show-DPVolumeList() {
  Write-DPMsg -Title -Message "--- Volume List..."
  Get-Volume
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< INIT FUNCTIONS >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-DiskPart
