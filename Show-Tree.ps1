param (
    [string]$Path = ".",
    [string]$OutputFile = "folder_structure.txt"
)

# Define exclusions
$excludedDirs = @("venv", ".pytest_cache", ".git", ".vs", "__pycache__")
$excludedFiles = @(".gitignore", "TODO.md")

function Show-Tree {
    param (
        [string]$CurrentPath,
        [string]$Indent = ""
    )
    
    $items = Get-ChildItem -LiteralPath $CurrentPath -Force | Sort-Object {
        if ($_.PSIsContainer) { 0 } else { 1 }
    }, Name
    
    $lastIndex = $items.Count - 1
    
    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLast = ($i -eq $lastIndex)
        $pointer = if ($isLast) { "└── " } else { "├── " }
        
        if ($item.PSIsContainer) {
            if ($excludedDirs -contains $item.Name) { continue }
            $line = "$Indent$pointer$item"
            $global:Output += $line
            
            if ($isLast) {
                $newIndent = "$Indent    "
            } else {
                $newIndent = "$Indent│   "
            }
            Show-Tree -CurrentPath $item.FullName -Indent $newIndent
        } else {
            if ($excludedFiles -contains $item.Name) { continue }
            
            # Get file timestamps with 3-letter month format
            $created = $item.CreationTime.ToString("yyyy-MMM-dd HH:mm")
            $modified = $item.LastWriteTime.ToString("yyyy-MMM-dd HH:mm")
            
            # Format: filename [Created: date | Modified: date]
            $line = "$Indent$pointer$($item.Name) [Created: $created | Modified: $modified]"
            $global:Output += $line
        }
    }
}

# Main execution
$global:Output = @()
Show-Tree -CurrentPath $Path
$Output | Set-Content -Encoding utf8 $OutputFile
Write-Host "`n✅ Folder structure saved to '$OutputFile'"