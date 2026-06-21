param(
    [Parameter(Mandatory = $true)]
    [string]$SourceMdbCopyPath,

    [string]$ExportRoot = (Join-Path $PSScriptRoot '..\exported-access-source')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-AbsolutePath {
    param([string]$Path)

    return [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Path).Path)
}

function ConvertTo-SafeFileName {
    param([string]$Name)

    $safeName = $Name
    foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {
        $safeName = $safeName.Replace($char, '_')
    }

    return $safeName.Trim()
}

function New-ObjectExportRecord {
    param(
        [string]$Kind,
        [string]$Name,
        [string]$Path,
        [string]$Status
    )

    [pscustomobject]@{
        Kind   = $Kind
        Name   = $Name
        Path   = $Path
        Status = $Status
    }
}

function Export-AccessCollection {
    param(
        [Parameter(Mandatory = $true)] $Collection,
        [Parameter(Mandatory = $true)] [int]$ObjectType,
        [Parameter(Mandatory = $true)] [string]$Kind,
        [Parameter(Mandatory = $true)] [string]$TargetFolder,
        [Parameter(Mandatory = $true)] $AccessApp
    )

    $records = New-Object System.Collections.Generic.List[object]

    foreach ($item in $Collection) {
        $name = $item.Name
        if ([string]::IsNullOrWhiteSpace($name)) {
            continue
        }

        $fileName = ConvertTo-SafeFileName $name
        $targetPath = Join-Path $TargetFolder ($fileName + '.txt')

        try {
            $AccessApp.SaveAsText($ObjectType, $name, $targetPath)
            $records.Add((New-ObjectExportRecord -Kind $Kind -Name $name -Path $targetPath -Status 'exported'))
        }
        catch {
            throw "Failed to export $Kind '$name' to '$targetPath'. $($_.Exception.Message)"
        }
    }

    return $records
}

try {
    $repoRoot = Resolve-AbsolutePath (Join-Path $PSScriptRoot '..')
    $sourceResolved = Resolve-AbsolutePath $SourceMdbCopyPath
    $originalMdbPath = Resolve-AbsolutePath (Join-Path $repoRoot 'Trend plus.mdb')

    if ([System.IO.Path]::GetExtension($sourceResolved).ToLowerInvariant() -ne '.mdb') {
        throw "Source must be an MDB copy. Refusing path: $sourceResolved"
    }

    if ($sourceResolved -eq $originalMdbPath) {
        throw "Refusing to export from the original MDB. Use a copied MDB instead: $sourceResolved"
    }

    if (-not (Test-Path -LiteralPath $sourceResolved)) {
        throw "Source MDB copy does not exist: $sourceResolved"
    }

    if ([System.IO.Path]::IsPathRooted($ExportRoot)) {
        $exportRootResolved = [System.IO.Path]::GetFullPath($ExportRoot)
    }
    else {
        $exportRootResolved = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $ExportRoot))
    }
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
    $runRoot = Join-Path $exportRootResolved ("run_$timestamp")
    $queryFolder = Join-Path $runRoot 'queries'
    $formFolder = Join-Path $runRoot 'forms'
    $reportFolder = Join-Path $runRoot 'reports'
    $moduleFolder = Join-Path $runRoot 'modules'

    foreach ($folder in @($runRoot, $queryFolder, $formFolder, $reportFolder, $moduleFolder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }

    $access = $null
    $results = New-Object System.Collections.Generic.List[object]

    try {
        $access = New-Object -ComObject Access.Application
    }
    catch {
        throw "Microsoft Access COM automation is unavailable. $($_.Exception.Message)"
    }

    try {
        $access.Visible = $false
        $access.UserControl = $false
        $access.OpenCurrentDatabase($sourceResolved, $false, '')

        $db = $access.CurrentDb()

        $queryDefs = @($db.QueryDefs | Where-Object { $_.Name -notlike 'MSys*' })
        $results.AddRange((Export-AccessCollection -Collection $queryDefs -ObjectType 1 -Kind 'query' -TargetFolder $queryFolder -AccessApp $access))

        $forms = @($access.CurrentProject.AllForms)
        $results.AddRange((Export-AccessCollection -Collection $forms -ObjectType 2 -Kind 'form' -TargetFolder $formFolder -AccessApp $access))

        $reports = @($access.CurrentProject.AllReports)
        $results.AddRange((Export-AccessCollection -Collection $reports -ObjectType 3 -Kind 'report' -TargetFolder $reportFolder -AccessApp $access))

        $modules = @($access.CurrentProject.AllModules)
        $results.AddRange((Export-AccessCollection -Collection $modules -ObjectType 5 -Kind 'module' -TargetFolder $moduleFolder -AccessApp $access))

        $manifestPath = Join-Path $runRoot 'export-manifest.txt'
        $manifestLines = @(
            'Access source export manifest'
            "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
            "Source MDB copy: $sourceResolved"
            "Original MDB: $originalMdbPath"
            "Export root: $runRoot"
            "Query count: $((@($results | Where-Object { $_.Kind -eq 'query' })).Count)"
            "Form count: $((@($results | Where-Object { $_.Kind -eq 'form' })).Count)"
            "Report count: $((@($results | Where-Object { $_.Kind -eq 'report' })).Count)"
            "Module count: $((@($results | Where-Object { $_.Kind -eq 'module' })).Count)"
            ''
            'Exported objects:'
        )

        foreach ($record in $results) {
            $manifestLines += "$($record.Kind)`t$($record.Name)`t$($record.Status)`t$($record.Path)"
        }

        Set-Content -LiteralPath $manifestPath -Value ($manifestLines -join [Environment]::NewLine) -Encoding UTF8

        Write-Host 'Source export completed successfully.'
        Write-Host "Source : $sourceResolved"
        Write-Host "Export : $runRoot"
        Write-Host "Manifest: $manifestPath"
        Write-Host "Counts  : queries=$((@($results | Where-Object { $_.Kind -eq 'query' })).Count) forms=$((@($results | Where-Object { $_.Kind -eq 'form' })).Count) reports=$((@($results | Where-Object { $_.Kind -eq 'report' })).Count) modules=$((@($results | Where-Object { $_.Kind -eq 'module' })).Count)"
    }
    finally {
        try {
            if ($access -ne $null) {
                $access.CloseCurrentDatabase()
                $access.Quit()
            }
        }
        catch {
            # Best-effort cleanup only.
        }

        if ($access -ne $null) {
            [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($access) | Out-Null
        }
    }
}
catch {
    Write-Error $_
    Write-Host ''
    Write-Host 'Manual fallback instructions:'
    Write-Host '1. Use a copied MDB only, never the original Trend plus.mdb.'
    Write-Host '2. Open the copied MDB in Microsoft Access with startup actions disabled if needed.'
    Write-Host '3. Export queries, forms, reports, and modules with SaveAsText.'
    Write-Host '4. Save the exported text files under exported-access-source\'
    Write-Host '5. Follow docs/SOURCE_EXPORT_INSTRUCTIONS.md for the manual command list.'
    exit 1
}
