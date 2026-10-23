function Assert-HowToGrowTestDiagnostics {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$LogText,
        [Parameter(Mandatory = $true)][ValidateSet('Import', 'Tests')][string]$Phase
    )

    # These are deliberate negative fixtures, not permission to accept profile,
    # sampler, metadata or other engine errors in general. Each occurs once in
    # the complete regression suite. Match the entire diagnostic exactly.
    $expectedFixtureLines = @'
ERROR: Plant profile 'basil_genovese' has invalid behavior_ids: phase79_invalid_type
ERROR: Plant profile 'basil_genovese' has duplicate behavior id 'resilient_leaves': phase79_duplicate
ERROR: Plant profile 'basil_genovese' has an unknown behavior id 'unknown_behavior': phase79_unknown
ERROR: Plant profile 'basil_genovese' has a non-canonical behavior id ' resilient_leaves ': phase79_whitespace
ERROR: Plant catalog manifest contains duplicate id 'basil_genovese': phase80_duplicate_id
ERROR: Plant catalog manifest contains an invalid or duplicate path 'res://data/plants/basil.json': phase80_duplicate_path
ERROR: Plant catalog manifest default_profile_id is not listed: phase80_missing_default
ERROR: Plant catalog id/profile mismatch for 'phase80_profile_mismatch': phase80_mismatch_manifest
ERROR: Plant catalog manifest references a missing profile 'res://data/plants/phase80_missing.json': phase80_missing_profile_manifest
ERROR: Plant profile 'basil_genovese' has a non-integer field 'seed_price': phase91_fractional_price
ERROR: Plant profile 'basil_genovese' has an out-of-range dry_matter_ratio: phase91_zero_ratio
ERROR: Plant profile 'basil_genovese' has inverted ideal care intervals: phase91_inverted_interval
ERROR: Plant profile 'basil_genovese' has a non-numeric field 'water_loss_per_hour': phase91_nonfinite_loss
ERROR: Plant profile 'basil_genovese' has inconsistent biomass constraints: base_fresh_yield_g exceeds max_live_biomass_g: phase91_impossible_biomass
ERROR: Plant profile 'basil_genovese' has an invalid lifecycle field 'care_issue_limit': phase91_fractional_care_limit
ERROR: Temporary save could not create a validated primary save: Failed
ERROR: Plant profile 'thymus_vulgaris' is missing field 'dry_growth_moisture_min': phase102_missing_behavior_band
ERROR: Plant profile 'thymus_vulgaris' has an out-of-range or inverted behavior band for 'dry_soil_vigor': phase102_inverted_behavior_band
'@ -split '\r?\n'
    $allowedCounts = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
    if ($Phase -eq 'Tests') {
        foreach ($message in $expectedFixtureLines) {
            $allowedCounts[$message] = 0
        }
    }

    $unexpected = [System.Collections.Generic.List[string]]::new()
    $expectedCount = 0
    foreach ($line in ($LogText -split '\r?\n')) {
        if ($line -notmatch '^\s*(?:(?:SCRIPT|USER)\s+)?ERROR:') {
            continue
        }
        $message = $line.Trim()
        if (-not $allowedCounts.ContainsKey($message)) {
            $unexpected.Add($message)
            continue
        }
        $allowedCounts[$message] += 1
        if ($allowedCounts[$message] -gt 1) {
            $unexpected.Add("Repeated negative-fixture diagnostic: $message")
            continue
        }
        $expectedCount += 1
    }

    if ($unexpected.Count -gt 0) {
        throw "Unexpected Godot $Phase diagnostics ($($unexpected.Count)):`n$($unexpected -join "`n")"
    }
    return [pscustomobject]@{
        Phase = $Phase
        ExpectedFixtureErrorCount = $expectedCount
        Status = 'PASSED'
    }
}
