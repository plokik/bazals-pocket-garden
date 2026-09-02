function Resolve-HowToGrowGodotExecutable {
    [CmdletBinding()]
    param(
        [string]$ExplicitPath = '',
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $candidates = [System.Collections.Generic.List[string]]::new()
    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        $candidates.Add($ExplicitPath)
    }
    if (-not [string]::IsNullOrWhiteSpace($env:HOW_TO_GROW_GODOT)) {
        $candidates.Add($env:HOW_TO_GROW_GODOT)
    }

    $normalizedProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
    $projectParent = Split-Path -Parent $normalizedProjectRoot
    $candidates.Add((Join-Path $projectParent 'Godot_v4.7-stable_win64.exe'))
    $candidates.Add((Join-Path $normalizedProjectRoot 'Godot_v4.7-stable_win64.exe'))

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    foreach ($name in @('godot4', 'godot')) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) {
            return $command.Source
        }
    }

    throw 'Godot 4.7 was not found. Pass -GodotPath, set HOW_TO_GROW_GODOT, or place Godot_v4.7-stable_win64.exe beside the project directory.'
}
