# [mvsepclient](https://www.powershellgallery.com/packages/mvsepclient)

🔥 Blazingly fast MvsepClient PowerShell module

[API](https://mvsep.com/user-api)

[![Downloads](https://img.shields.io/powershellgallery/dt/mvsepclient.svg?style=flat&logo=powershell&color=blue)](https://www.powershellgallery.com/packages/mvsepclient)

## Usage

```PowerShell
Install-Module mvsepclient
```

then

```PowerShell
Import-Module mvsepclient

$client = [MvsepClient]::new("YOUR_API_KEY")

# Get available algorithms
$algos = $client.GetAlgorithms()

# Process a directory of files
$options = @{
    sep_type = 48 # MelBand Roformer
    add_opt1 = 1
}
$client.ProcessDirectory("./input", "./output", $options)
```

## License

This project is licensed under the [WTFPL License](LICENSE).
