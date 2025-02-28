﻿<#
.SYNOPSIS
	Fetches updates for all Git repositories in a folder
.DESCRIPTION
	This PowerShell script fetches updates for all Git repositories in a folder (including submodules).
.PARAMETER ParentDir
	Specifies the path to the parent folder
.EXAMPLE
	PS> ./fetch-repos C:\MyRepos
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz / License: CC0
#>

param([string]$ParentDir = "$PWD")

try {
	$StopWatch = [system.diagnostics.stopwatch]::startNew()

	if (-not(test-path "$ParentDir" -pathType container)) { throw "Can't access directory: $ParentDir" }

	$Null = (git --version)
	if ($lastExitCode -ne "0") { throw "Can't execute 'git' - make sure Git is installed and available" }

	$Folders = (get-childItem "$ParentDir" -attributes Directory)
	$NumFolders = $Folders.Count
	$ParentDirName = (get-item "$ParentDir").Name
	"Found $NumFolders subfolders in 📂$ParentDirName..."

	[int]$Step = 1
	foreach ($Folder in $Folders) {
		$FolderName = (get-item "$Folder").Name
		"⏳ Step $Step/$($NumFolders): Fetching 📂$FolderName..."

		& git -C "$Folder" fetch --all --recurse-submodules --prune --prune-tags --force
		if ($lastExitCode -ne "0") { throw "'git fetch' in $FolderName failed" }

		$Step++
	}

	[int]$Elapsed = $StopWatch.Elapsed.TotalSeconds
	"✔️ fetched $NumFolders Git repositories at 📂$ParentDirName in $Elapsed sec"
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
