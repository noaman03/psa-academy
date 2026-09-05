@echo off
echo Fixing imports across all Dart files...
echo.

cd /d "c:\AMIT flutter\psa_academy\lib"

REM Create a temporary PowerShell script for find and replace
echo $files = Get-ChildItem -Path "." -Recurse -Filter "*.dart" > temp_fix.ps1
echo foreach ($file in $files) { >> temp_fix.ps1
echo     $content = Get-Content $file.FullName -Raw >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/pages/home_screen/", "from 'package:psa_academy/presentation/pages/" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/pages/", "from 'package:psa_academy/presentation/pages/auth/" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/widgets/error_popup", "from 'package:psa_academy/presentation/widgets/dialogs/error_popup" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/widgets/qr_popup", "from 'package:psa_academy/presentation/widgets/dialogs/qr_popup" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/widgets/addExercisePage", "from 'package:psa_academy/presentation/widgets/dialogs/addExercisePage" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/widgets/", "from 'package:psa_academy/presentation/widgets/common/" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/service/provider/", "from 'package:psa_academy/presentation/providers/" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/service/firebase/", "from 'package:psa_academy/data/datasources/remote/" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/utils/constants/", "from 'package:psa_academy/core/constants/" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/utils/", "from 'package:psa_academy/core/utils/" >> temp_fix.ps1
echo     $content = $content -replace "from 'package:psa_academy/controller/", "from 'package:psa_academy/core/utils/" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/pages/home_screen/", "import 'package:psa_academy/presentation/pages/" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/pages/", "import 'package:psa_academy/presentation/pages/auth/" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/widgets/error_popup", "import 'package:psa_academy/presentation/widgets/dialogs/error_popup" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/widgets/qr_popup", "import 'package:psa_academy/presentation/widgets/dialogs/qr_popup" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/widgets/addExercisePage", "import 'package:psa_academy/presentation/widgets/dialogs/addExercisePage" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/widgets/", "import 'package:psa_academy/presentation/widgets/common/" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/service/provider/", "import 'package:psa_academy/presentation/providers/" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/service/firebase/", "import 'package:psa_academy/data/datasources/remote/" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/utils/constants/", "import 'package:psa_academy/core/constants/" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/utils/", "import 'package:psa_academy/core/utils/" >> temp_fix.ps1
echo     $content = $content -replace "import 'package:psa_academy/controller/", "import 'package:psa_academy/core/utils/" >> temp_fix.ps1
echo     Set-Content -Path $file.FullName -Value $content >> temp_fix.ps1
echo     Write-Host "Fixed: $($file.FullName)" >> temp_fix.ps1
echo } >> temp_fix.ps1

REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -File temp_fix.ps1

REM Clean up
del temp_fix.ps1

echo.
echo Import fixes completed!
echo.
echo Next steps:
echo 1. Review the changes
echo 2. Run 'flutter pub get'
echo 3. Run 'flutter analyze' to check for any remaining issues
echo 4. Test your app
echo.
pause
