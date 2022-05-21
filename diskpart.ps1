<#
.SYNOPSIS
.DESCRIPTION
#>

#Requires -Version 7.2
#Requires -RunAsAdministrator

Param(
  [Parameter(
    Mandatory,
    HelpMessage=""
  )]
  [Alias("DN")]
  [int]$DiskNumber,

  [Parameter(
    Mandatory,
    HelpMessage=""
  )]
  [Alias("DL")]
  [string]$DriveLetter,

  [Parameter(
    Mandatory,
    HelpMessage=""
  )]
  [Alias("FS")]
  [string]$FileSystem,

  [Parameter(
    Mandatory,
    HelpMessage=""
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

  Write-Msg -Title -Message "--- [DISK $($DiskNumber)] Clear Disk..."
  Clear-Disk -Number $DiskNumber -RemoveData -RemoveOEM
  Start-Sleep -s $sleep

  Write-Msg -Title -Message "--- [DISK $($DiskNumber)] Initialize Disk..."
  Initialize-Disk -Number $DiskNumber -PartitionStyle GPT
  Start-Sleep -s $sleep

  Write-Msg -Title -Message "--- [DISK $($DiskNumber)] Create Partition..."
  New-Partition -DiskNumber $DiskNumber -UseMaximumSize -DriveLetter "$($DriveLetter)"
  Start-Sleep -s $sleep

  Write-Msg -Title -Message "--- [DISK $($DiskNumber)] Format Disk Volume ($($DriveLetter) / $($FileSystem))..."
  Format-Volume -DriveLetter "$($DriveLetter)" -FileSystem "$($FileSystem)" -Force -NewFileSystemLabel "$($FileSystemLabel)"
  Start-Sleep -s $sleep
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

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< INIT FUNCTIONS >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-DiskPart
