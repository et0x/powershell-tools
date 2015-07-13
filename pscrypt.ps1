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

function Encrypt-String
{
    Param(
        [string]$String
    )
    
    $PlaintextBytes = Convert-StringToByteArray -String $String
    
    $AES = New-Object System.Security.Cryptography.AesManaged
    $AES.Key = @(1..32)
    $AES.IV =  @(1..16)
    $AES.Padding = "Zeros"
    $Encryptor = $AES.CreateEncryptor()
    
    $MemoryStream = New-Object -TypeName System.IO.MemoryStream
    $StreamMode   = [System.Security.Cryptography.CryptoStreamMode]::Write
    
    $CryptoStream = New-Object -TypeName System.Security.Cryptography.CryptoStream -ArgumentList $MemoryStream,$Encryptor,$StreamMode
    $CryptoStream.Write($PlaintextBytes, 0, $PlaintextBytes.Length)
    
    [int[]]$Bytes =  [int[]]$MemoryStream.ToArray()
    $Bytes
    $CryptoStream.Dispose()
    $MemoryStream.Dispose()
    return $Bytes
}
