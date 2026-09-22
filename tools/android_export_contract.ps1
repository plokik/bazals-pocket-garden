function ConvertFrom-GodotConfigValue {
    param([AllowEmptyString()][string]$Value)

    if ($Value.Length -ge 2 -and $Value[0] -eq '"' -and $Value[$Value.Length - 1] -eq '"') {
        return $Value.Substring(1, $Value.Length - 2)
    }
    return $Value
}

function Get-AndroidExportPresetContracts {
    param([Parameter(Mandatory = $true)][string]$PresetPath)

    $records = @{}
    $currentIndex = $null
    $inOptions = $false
    foreach ($line in Get-Content -LiteralPath $PresetPath) {
        if ($line -match '^\[preset\.(\d+)\]$') {
            $currentIndex = [int]$Matches[1]
            $records[$currentIndex] = @{
                Header = @{}
                Options = @{}
            }
            $inOptions = $false
            continue
        }
        if ($line -match '^\[preset\.(\d+)\.options\]$') {
            $currentIndex = [int]$Matches[1]
            if (-not $records.ContainsKey($currentIndex)) {
                throw "Android export options reference a missing preset index: $currentIndex"
            }
            $inOptions = $true
            continue
        }
        if ($null -eq $currentIndex -or $line -notmatch '^([^=]+)=(.*)$') {
            continue
        }
        $target = if ($inOptions) { $records[$currentIndex].Options } else { $records[$currentIndex].Header }
        $target[$Matches[1]] = $Matches[2]
    }

    $contracts = foreach ($index in @($records.Keys | Sort-Object)) {
        $record = $records[$index]
        $header = $record.Header
        $options = $record.Options
        if (-not $header.ContainsKey('name') -or -not $header.ContainsKey('platform')) {
            throw "Android export preset $index is missing its name or platform."
        }
        [pscustomobject]@{
            Index = $index
            Name = ConvertFrom-GodotConfigValue $header['name']
            Platform = ConvertFrom-GodotConfigValue $header['platform']
            ExportFilter = ConvertFrom-GodotConfigValue $header['export_filter']
            ExcludeFilter = ConvertFrom-GodotConfigValue $header['exclude_filter']
            ExportPath = ConvertFrom-GodotConfigValue $header['export_path']
            ExportFormat = [int]$options['gradle_build/export_format']
            MinSdk = [int](ConvertFrom-GodotConfigValue $options['gradle_build/min_sdk'])
            TargetSdk = [int](ConvertFrom-GodotConfigValue $options['gradle_build/target_sdk'])
            ArmeabiV7a = $options['architectures/armeabi-v7a'] -eq 'true'
            Arm64V8a = $options['architectures/arm64-v8a'] -eq 'true'
            X86 = $options.ContainsKey('architectures/x86') -and $options['architectures/x86'] -eq 'true'
            X8664 = $options.ContainsKey('architectures/x86_64') -and $options['architectures/x86_64'] -eq 'true'
            PackageName = ConvertFrom-GodotConfigValue $options['package/unique_name']
            AppCategory = [int]$options['package/app_category']
            VersionCode = [int]$options['version/code']
            VersionName = ConvertFrom-GodotConfigValue $options['version/name']
        }
    }
    return @($contracts)
}

function Assert-AndroidPresetSetContract {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][string]$PresetName,
        [string]$ExpectedVersionName = '0.70.0-rc60',
        [int]$ExpectedVersionCode = 77,
        [int]$ExpectedSaveSchema = 41
    )

    $presetPath = Join-Path $ProjectRoot 'export_presets.cfg'
    $projectPath = Join-Path $ProjectRoot 'project.godot'
    $gameSessionPath = Join-Path $ProjectRoot 'scripts\game_session.gd'
    $presetText = Get-Content -LiteralPath $presetPath -Raw
    $projectText = Get-Content -LiteralPath $projectPath -Raw
    $gameSessionText = Get-Content -LiteralPath $gameSessionPath -Raw
    $presets = @(Get-AndroidExportPresetContracts -PresetPath $presetPath)

    $requiredPresetNames = @('Android', 'Android Release AAB', 'Android Emulator x86_64')
    $requiredPresets = @($presets | Where-Object { $requiredPresetNames -contains $_.Name })
    foreach ($requiredPresetName in $requiredPresetNames) {
        if (@($requiredPresets | Where-Object { $_.Name -ceq $requiredPresetName }).Count -ne 1) {
            throw "Required Android export preset was not found exactly once: $requiredPresetName"
        }
    }
    $selected = @($presets | Where-Object { $_.Name -ceq $PresetName })
    if ($selected.Count -ne 1) {
        throw "Android export preset was not found exactly once: $PresetName"
    }
    $projectVersionMatch = [regex]::Match($projectText, '(?m)^config/version="([^"]+)"$')
    if (-not $projectVersionMatch.Success -or $projectVersionMatch.Groups[1].Value -cne $ExpectedVersionName) {
        throw "project.godot version must be $ExpectedVersionName."
    }
    if ($projectText -notmatch '(?m)^window/handheld/orientation=1$') {
        throw 'The project must remain locked to portrait handheld orientation.'
    }
    $saveSchemaMatch = [regex]::Match($gameSessionText, '(?m)^\s*const\s+SAVE_SCHEMA(?:\s*:\s*\w+)?\s*(?::=|=)\s*(\d+)\b')
    if (-not $saveSchemaMatch.Success -or [int]$saveSchemaMatch.Groups[1].Value -ne $ExpectedSaveSchema) {
        throw "Save schema must remain $ExpectedSaveSchema."
    }
    if ($presetText -match '(?m)^keystore/release_password=".+"$') {
        throw 'Release password must not be stored in export_presets.cfg.'
    }

    $excludeFilters = @($requiredPresets | ForEach-Object { $_.ExcludeFilter } | Sort-Object -Unique)
    if ($excludeFilters.Count -ne 1) {
        throw 'Android export filters have drifted between presets.'
    }

    foreach ($preset in $requiredPresets) {
        if ($preset.ExportFilter -cne 'all_resources') {
            throw "Android preset must retain export_filter=all_resources: $($preset.Name)"
        }
        $excludePatterns = @($preset.ExcludeFilter.Split(',') | ForEach-Object { $_.Trim() })
        foreach ($requiredExclusion in @(
            'assets/ui/visual/phase149/player_room/qa/**',
            'assets/ui/visual/phase150/greenhouse/qa/**',
            'assets/ui/visual/phase150/greenhouse/greenhouse_phase150_registered_clean_donor_candidate_v1.png'
        )) {
            if ($requiredExclusion -cnotin $excludePatterns) {
                throw "Android preset is missing the audited QA/donor exclusion: $($preset.Name) -> $requiredExclusion"
            }
        }
        if ($preset.Platform -cne 'Android' -or
            $preset.PackageName -cne 'com.howtogrow.game' -or
            $preset.MinSdk -ne 24 -or
            $preset.TargetSdk -ne 36 -or
            $preset.AppCategory -ne 2 -or
            $preset.VersionCode -ne $ExpectedVersionCode) {
            throw "Android preset contract mismatch: $($preset.Name)"
        }
        $isEmulator = $preset.Name -ceq 'Android Emulator x86_64'
        $expectedPresetVersion = if ($isEmulator) { "$ExpectedVersionName-emulator" } else { $ExpectedVersionName }
        if ($preset.VersionName -cne $expectedPresetVersion) {
            throw "Android preset version mismatch: $($preset.Name) -> $($preset.VersionName)"
        }
        if ($isEmulator) {
            if ($preset.ExportFormat -ne 0 -or $preset.ArmeabiV7a -or $preset.Arm64V8a -or $preset.X86 -or -not $preset.X8664) {
                throw 'Android emulator preset must export an x86_64-only APK.'
            }
        } else {
            $expectedFormat = if ($preset.Name -ceq 'Android Release AAB') { 1 } else { 0 }
            if ($preset.ExportFormat -ne $expectedFormat -or $preset.ArmeabiV7a -or -not $preset.Arm64V8a -or $preset.X86 -or $preset.X8664) {
                throw "Android production preset must export arm64-v8a only: $($preset.Name)"
            }
        }
    }

    return $selected[0]
}

function Assert-AndroidQaDonorPayloadContract {
    param(
        [Parameter(Mandatory = $true)][string[]]$Entries,
        [Parameter(Mandatory = $true)][ValidateSet('APK', 'AAB')][string]$Format
    )

    $excludedPngNames = @(
        'phase149_canonical_reconstruction_qa.png',
        'phase149_layer_coverage_heatmap.png',
        'phase150_geometry_overlay.png',
        'phase150_registered_donor_difference_heatmap.png',
        'greenhouse_phase150_registered_clean_donor_candidate_v1.png'
    )
    # Godot puts the texture payload outside its source directory. Check each
    # audited basename in raw PNG, import-sidecar and hashed .ctex entry paths.
    $namesPattern = ($excludedPngNames | ForEach-Object { [regex]::Escape($_) }) -join '|'
    $entryPattern = '(?:^|/)(?:' + $namesPattern + ')(?:\.import|-[^/]+\.ctex)?$'
    foreach ($entry in $Entries) {
        if ($entry -match $entryPattern) {
            throw "$Format contains an audited QA/donor image payload: $entry"
        }
    }
    Write-Output "${Format}_QA_DONOR_PAYLOAD_CHECK=PASSED"
}

function Assert-AndroidMergedManifestContract {
    param(
        [Parameter(Mandatory = $true)][string]$ManifestText,
        [Parameter(Mandatory = $true)]$PresetContract
    )

    $requiredPatterns = @(
        ('package="' + [regex]::Escape($PresetContract.PackageName) + '"'),
        ('android:versionCode="' + $PresetContract.VersionCode + '"'),
        ('android:versionName="' + [regex]::Escape($PresetContract.VersionName) + '"'),
        ('android:minSdkVersion="' + $PresetContract.MinSdk + '"'),
        ('android:targetSdkVersion="' + $PresetContract.TargetSdk + '"'),
        'android:allowBackup="false"',
        'android:isGame="true"',
        'android:enableOnBackInvokedCallback="false"',
        'android:screenOrientation="(?:1|portrait)"',
        'android.permission.POST_NOTIFICATIONS',
        'android.permission.RECEIVE_BOOT_COMPLETED',
        'com.howtogrow.notifications.CareNotificationReceiver',
        'com.howtogrow.notifications.CareBootReceiver'
    )
    foreach ($pattern in $requiredPatterns) {
        if ($ManifestText -notmatch $pattern) {
            throw "Android manifest contract is missing: $pattern"
        }
    }
    if ($ManifestText -notmatch 'android:appCategory="(?:0|game)"') {
        throw 'Android manifest app category is not Game.'
    }

    $allowedPermissions = @(
        'android.permission.POST_NOTIFICATIONS',
        'android.permission.RECEIVE_BOOT_COMPLETED'
    )
    $declaredPermissions = @(
        [regex]::Matches(
            $ManifestText,
            '<uses-permission(?:-sdk-\d+)?\b[^>]*\bandroid:name="([^"]+)"'
        ) |
            ForEach-Object { $_.Groups[1].Value } |
            Sort-Object -Unique
    )
    $missingPermissions = @($allowedPermissions | Where-Object { $_ -cnotin $declaredPermissions })
    $unexpectedPermissions = @($declaredPermissions | Where-Object { $_ -cnotin $allowedPermissions })
    if ($missingPermissions.Count -gt 0 -or $unexpectedPermissions.Count -gt 0) {
        throw "Android permission allowlist mismatch. Missing: $($missingPermissions -join ', '); unexpected: $($unexpectedPermissions -join ', ')"
    }
}

function Assert-AndroidDexPrivacyContract {
    param([Parameter(Mandatory = $true)][string]$DexPackagesText)

    $forbiddenSdkTokens = @(
        'com.google.firebase',
        'com.google.android.gms',
        'com.google.android.ump',
        'com.google.ads',
        'com.android.billingclient',
        'io.sentry',
        'com.facebook',
        'com.appsflyer',
        'com.adjust.sdk',
        'com.amplitude',
        'com.mixpanel',
        'com.segment.analytics'
    )
    foreach ($token in $forbiddenSdkTokens) {
        if ($DexPackagesText -match [regex]::Escape($token)) {
            throw "Android artifact contains a forbidden analytics, ads, billing, attribution or social SDK token: $token"
        }
    }
}

function Assert-AndroidArchiveAbiContract {
    param(
        [Parameter(Mandatory = $true)][string[]]$Entries,
        [Parameter(Mandatory = $true)]$PresetContract,
        [Parameter(Mandatory = $true)][ValidateSet('APK', 'AAB')][string]$Format
    )

    $prefix = if ($Format -ceq 'APK') { 'lib/' } else { 'base/lib/' }
    $nativePattern = '^' + [regex]::Escape($prefix) + '([^/]+)/.+\.so$'
    $nativeEntries = @($Entries | Where-Object { $_ -match $nativePattern })
    if ($nativeEntries.Count -lt 1) {
        throw "$Format does not contain native Android libraries."
    }
    $abis = @($nativeEntries | ForEach-Object {
        [regex]::Match($_, $nativePattern).Groups[1].Value
    } | Sort-Object -Unique)
    $expectedAbi = if ($PresetContract.X8664) { 'x86_64' } else { 'arm64-v8a' }
    if ($abis.Count -ne 1 -or $abis[0] -cne $expectedAbi) {
        throw "$Format ABI mismatch. Expected only $expectedAbi, found: $($abis -join ', ')"
    }
    $godotEntry = $prefix + $expectedAbi + '/libgodot_android.so'
    if ($Entries -notcontains $godotEntry) {
        throw "$Format is missing the expected Godot native library: $godotEntry"
    }
}

function Assert-NativeElf16KiBAlignment {
    param(
        [Parameter(Mandatory = $true)][string]$ArchivePath,
        [Parameter(Mandatory = $true)][ValidateSet('APK', 'AAB')][string]$Format
    )

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $prefix = if ($Format -ceq 'APK') { 'lib/' } else { 'base/lib/' }
    $archive = [System.IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        $libraries = @($archive.Entries | Where-Object { $_.FullName.StartsWith($prefix, [System.StringComparison]::Ordinal) -and $_.FullName.EndsWith('.so', [System.StringComparison]::Ordinal) })
        if ($libraries.Count -lt 1) {
            throw "$Format has no native ELF libraries to inspect."
        }
        foreach ($library in $libraries) {
            $memory = [System.IO.MemoryStream]::new()
            $stream = $library.Open()
            try {
                $stream.CopyTo($memory)
            } finally {
                $stream.Dispose()
            }
            $bytes = $memory.ToArray()
            $memory.Dispose()
            if ($bytes.Length -lt 64 -or $bytes[0] -ne 0x7f -or $bytes[1] -ne 0x45 -or $bytes[2] -ne 0x4c -or $bytes[3] -ne 0x46) {
                throw "Native library is not a valid ELF file: $($library.FullName)"
            }
            if ($bytes[5] -ne 1) {
                throw "Only little-endian Android ELF files are supported: $($library.FullName)"
            }
            $elfClass = $bytes[4]
            if ($elfClass -eq 2) {
                $programHeaderOffset = [int][BitConverter]::ToUInt64($bytes, 32)
                $programHeaderSize = [int][BitConverter]::ToUInt16($bytes, 54)
                $programHeaderCount = [int][BitConverter]::ToUInt16($bytes, 56)
                $alignmentOffset = 48
                $alignmentWidth = 8
            } elseif ($elfClass -eq 1) {
                $programHeaderOffset = [int][BitConverter]::ToUInt32($bytes, 28)
                $programHeaderSize = [int][BitConverter]::ToUInt16($bytes, 42)
                $programHeaderCount = [int][BitConverter]::ToUInt16($bytes, 44)
                $alignmentOffset = 28
                $alignmentWidth = 4
            } else {
                throw "Unsupported ELF class in $($library.FullName): $elfClass"
            }
            $loadSegmentCount = 0
            for ($index = 0; $index -lt $programHeaderCount; $index++) {
                $headerOffset = $programHeaderOffset + ($index * $programHeaderSize)
                if ($headerOffset -lt 0 -or $headerOffset + $programHeaderSize -gt $bytes.Length) {
                    throw "ELF program headers are truncated: $($library.FullName)"
                }
                if ([BitConverter]::ToUInt32($bytes, $headerOffset) -ne 1) {
                    continue
                }
                $loadSegmentCount++
                $alignment = if ($alignmentWidth -eq 8) {
                    [BitConverter]::ToUInt64($bytes, $headerOffset + $alignmentOffset)
                } else {
                    [uint64][BitConverter]::ToUInt32($bytes, $headerOffset + $alignmentOffset)
                }
                if ($alignment -lt 16384) {
                    throw "ELF LOAD alignment is below 16 KiB: $($library.FullName) -> $alignment bytes"
                }
            }
            if ($loadSegmentCount -lt 1) {
                throw "ELF has no LOAD segments: $($library.FullName)"
            }
        }
    } finally {
        $archive.Dispose()
    }
}

function Assert-Apk16KiBAlignment {
    param(
        [Parameter(Mandatory = $true)][string]$ApkPath,
        [Parameter(Mandatory = $true)][string]$ZipAlignPath
    )

    $zipAlignOutput = @(& $ZipAlignPath -c -P 16 -v 4 $ApkPath 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "APK zip alignment is not 16 KiB compatible:`n$($zipAlignOutput -join "`n")"
    }
    Assert-NativeElf16KiBAlignment -ArchivePath $ApkPath -Format APK
}

function Get-LocalBundletoolClasspath {
    param([Parameter(Mandatory = $true)][string]$GradleHome)

    $moduleCache = Join-Path $GradleHome 'caches\modules-2\files-2.1'
    $dependencyRoots = @(
        'com.android.tools.build\bundletool',
        'com.android.tools.build\aapt2-proto',
        'com.google.auto.value\auto-value-annotations',
        'com.google.errorprone\error_prone_annotations',
        'com.google.guava',
        'com.google.protobuf',
        'com.google.dagger\dagger',
        'javax.inject\javax.inject',
        'org.bitbucket.b_c\jose4j',
        'org.slf4j\slf4j-api',
        'com.google.code.gson\gson',
        'org.checkerframework\checker-qual',
        'com.google.j2objc\j2objc-annotations',
        'com.google.code.findbugs\jsr305'
    )
    $jars = [System.Collections.Generic.List[string]]::new()
    foreach ($relativeRoot in $dependencyRoots) {
        $root = Join-Path $moduleCache $relativeRoot
        if (-not (Test-Path -LiteralPath $root -PathType Container)) {
            continue
        }
        Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.jar' | ForEach-Object {
            $jars.Add($_.FullName)
        }
    }
    if (-not ($jars | Where-Object { [System.IO.Path]::GetFileName($_) -match '^bundletool-[\d.]+\.jar$' })) {
        throw 'Local bundletool dependency is unavailable; AAB 16 KiB verification cannot run.'
    }
    return ($jars -join ';')
}

function Assert-Aab16KiBAlignment {
    param(
        [Parameter(Mandatory = $true)][string]$AabPath,
        [Parameter(Mandatory = $true)][string]$JavaPath,
        [Parameter(Mandatory = $true)][string]$GradleHome
    )

    $bundletoolClasspath = Get-LocalBundletoolClasspath -GradleHome $GradleHome
    $bundleConfig = @(& $JavaPath -cp $bundletoolClasspath com.android.tools.build.bundletool.BundleToolMain dump config "--bundle=$AabPath" 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "bundletool could not inspect BundleConfig.pb:`n$($bundleConfig -join "`n")"
    }
    $bundleConfigText = $bundleConfig -join "`n"
    if ($bundleConfigText -notmatch 'page_alignment:\s*PAGE_ALIGNMENT_16K') {
        throw 'AAB BundleConfig.pb does not declare PAGE_ALIGNMENT_16K.'
    }
    Assert-NativeElf16KiBAlignment -ArchivePath $AabPath -Format AAB
}
