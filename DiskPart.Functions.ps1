# -------------------------------------------------------------------------------------------------------------------- #
# MESSAGES.
# -------------------------------------------------------------------------------------------------------------------- #

function Write-DPMsg() {
  param (
    [Alias("M")]
    [string]$Message,

    [Alias("T")]
    [string]$Type,

    [Alias("A")]
    [string]$Action = "Continue"
  )

  switch ( $Type ) {
    "HL" {
      Write-Host "$($NL)--- $($Message)".ToUpper() -ForegroundColor Blue
    }
    "I" {
      Write-Information -MessageData "$($Message)" -InformationAction "$($Action)"
    }
    "W" {
      Write-Warning -Message "$($Message)" -WarningAction "$($Action)"
    }
    "E" {
      Write-Error -Message "$($Message)" -ErrorAction "$($Action)"
    }
    default {
      Write-Host "$($Message)"
    }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# DISK LIST.
# -------------------------------------------------------------------------------------------------------------------- #

function Show-DPDiskList() {
  Write-DPMsg -T "HL" -M "[DISK $($P_DiskNumber)] Disk List..."
  Get-Disk
}

# -------------------------------------------------------------------------------------------------------------------- #
# VOLUME LIST.
# -------------------------------------------------------------------------------------------------------------------- #

function Show-DPVolumeList() {
  Write-DPMsg -T "HL" -M "[DISK $($P_DiskNumber)] Volume List..."
  Get-Volume
}
