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
  [Alias("DN")]
  [int]$DiskNumber,

  [Parameter(
    Mandatory,
    HelpMessage="Specifies the specific drive letter to assign to the new partition."
  )]
  [Alias("DL")]
  [string]$DriveLetter,

  [Parameter(
    Mandatory,
    HelpMessage="Specifies the file system with which to format the volume. The acceptable values for this parameter are:NTFS, ReFS, exFAT, FAT32, and FAT."
  )]
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
  # Run.
  New-DiskPart
}

# -------------------------------------------------------------------------------------------------------------------- #
# DISK PARTITION.
# -------------------------------------------------------------------------------------------------------------------- #

function New-DiskPart() {
  # Sleep time.
  [int]$sleep = 5

  # Disk list.
  Start-DiskList

  # Clear disk.
  function Start-DiskClear() {
    Write-Msg -Title -Message "--- [DISK $($DiskNumber)] Clear Disk..."
    Clear-Disk -Number $DiskNumber -RemoveData -RemoveOEM -Confirm:$false
    Show-DiskList
    Start-Sleep -s $sleep
  }

  # Initialize disk.
  function Start-DiskInit() {
    Write-Msg -Title -Message "--- [DISK $($DiskNumber)] Initialize Disk..."
    Initialize-Disk -Number $DiskNumber -PartitionStyle "GPT"
    Show-DiskList
    Start-Sleep -s $sleep
  }

  # Create partition.
  function Start-DiskPartition() {
    Write-Msg -Title -Message "--- [DISK $($DiskNumber)] Create Partition..."
    New-Partition -DiskNumber $DiskNumber -UseMaximumSize -DriveLetter "$($DriveLetter)"
    Start-Sleep -s $sleep
  }

  # Format disk volume.
  function Start-DiskFormat() {
    Write-Msg -Title -Message "--- [DISK $($DiskNumber)] Format Disk Volume ($($DriveLetter) / $($FileSystem))..."
    Format-Volume -DriveLetter "$($DriveLetter)" -FileSystem "$($FileSystem)" -Force -NewFileSystemLabel "$($FileSystemLabel)"
    Show-VolumeList
    Start-Sleep -s $sleep
  }

  Start-DiskClear
  Start-DiskInit
  Start-DiskPartition
  Start-DiskFormat
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

function Write-Msg() {
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

function Show-DiskList() {
  Write-Msg -Title -Message "--- Disk List..."
  Get-Disk
}

function Show-VolumeList() {
  Write-Msg -Title -Message "--- Volume List..."
  Get-Volume
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< INIT FUNCTIONS >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-DiskPart
