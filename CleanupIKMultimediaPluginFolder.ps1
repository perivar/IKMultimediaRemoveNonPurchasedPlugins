#Elevate to administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

$sourceDirectoryx64 = "C:\Program Files\Steinberg\VSTPlugins"
$destinationDirectoryx64 = "C:\Program Files\Steinberg\VSTPlugins-Disabled"

$sourceDirectoryVST3 = "C:\Program Files\Common Files\VST3"
$destinationDirectoryVST3 = "C:\Program Files\Common Files\VST3-Disabled"

#Make sure we can find the exclude file
$fileExcludeListName = "PluginsToKeep.txt"
$fileExcludeListPath = Join-Path $PSScriptRoot $fileExcludeListName
$fileExcludeList = Get-Content $fileExcludeListPath

function MoveFilesExceptRecursively ($sourceDirectory, $destinationDirectory, $fileExcludeList) {
    #Create destinationDirectory if not exists
    if (-not (Test-Path -Path $destinationDirectory)) {
        New-Item -Path $destinationDirectory -ItemType Directory | Out-Null
    }
    #endregion

    #region move files (does not support recursive folders)
    Get-ChildItem $sourceDirectory -Filter "TR5 *" -File | 
    Where-Object { $_.Name -notin $fileExcludeList } | 	
    # To debug do a foreach on the list and output the filename
    #ForEach-Object {Write-Host $_.FullName}
    # Move file and force (overwrite if already exist) 
    Move-Item -Destination $destinationDirectory -Force
    #endregion

    #region move files (does support recursive folders)
    #Get-ChildItem $sourceDirectory -Recurse -Exclude $fileExcludeList | 
    #Move-Item -Destination { Join-Path $destinationDirectory $_.FullName.Substring($sourceDirectory.length) } -Force
    #endregion
}

Write-Host "Cleaning up $sourceDirectoryx64"
MoveFilesExceptRecursively $sourceDirectoryx64 $destinationDirectoryx64 $fileExcludeList

Write-Host "Cleaning up $sourceDirectoryVST3"
MoveFilesExceptRecursively $sourceDirectoryVST3 $destinationDirectoryVST3 $fileExcludeList
