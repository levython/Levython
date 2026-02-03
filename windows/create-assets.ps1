# PowerShell script to create installer assets
# Used by GitHub Actions

Write-Host "Creating installer assets..."

$assetsDir = "windows\assets"
New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null

# Create ICO file
$bitmap = New-Object System.Drawing.Bitmap(256, 256)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.FillRectangle([System.Drawing.Brushes]::DarkBlue, 0, 0, 256, 256)
$font = New-Object System.Drawing.Font("Arial", 180, [System.Drawing.FontStyle]::Bold)
$graphics.DrawString("L", $font, [System.Drawing.Brushes]::White, 40, 20)
$icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
$stream = [System.IO.File]::Create("$assetsDir\levython.ico")
$icon.Save($stream)
$stream.Close()
Write-Host "✓ Created levython.ico"

# Create large wizard image (164x314)
$large = New-Object System.Drawing.Bitmap(164, 314)
$g = [System.Drawing.Graphics]::FromImage($large)
$g.FillRectangle([System.Drawing.Brushes]::Navy, 0, 0, 164, 314)
$font1 = New-Object System.Drawing.Font("Arial", 48, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Levython", $font1, [System.Drawing.Brushes]::White, 5, 120)
$large.Save("$assetsDir\wizard-large.bmp")
Write-Host "✓ Created wizard-large.bmp"

# Create small wizard image (55x55)
$small = New-Object System.Drawing.Bitmap(55, 55)
$g2 = [System.Drawing.Graphics]::FromImage($small)
$g2.FillRectangle([System.Drawing.Brushes]::DarkBlue, 0, 0, 55, 55)
$font2 = New-Object System.Drawing.Font("Arial", 32, [System.Drawing.FontStyle]::Bold)
$g2.DrawString("L", $font2, [System.Drawing.Brushes]::White, 8, 8)
$small.Save("$assetsDir\wizard-small.bmp")
Write-Host "✓ Created wizard-small.bmp"

Write-Host "✓ All assets created successfully!"
