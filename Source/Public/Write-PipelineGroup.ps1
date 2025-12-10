Function Write-PipelineGroup {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $Header,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Body
    )

    Write-PipelineGroupStart $Header

    (& $Body) | ForEach-Object { Write-Host $_ }

    Write-PipelineGroupEnd
}
