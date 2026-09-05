@echo off
echo Creating Clean Architecture Folder Structure...

cd /d "c:\AMIT flutter\psa_academy\lib"

REM Create core folders
mkdir core\constants 2>nul
mkdir core\themes 2>nul
mkdir core\utils 2>nul
mkdir core\errors 2>nul

REM Create data folders
mkdir data\models 2>nul
mkdir data\datasources\remote 2>nul
mkdir data\repositories 2>nul

REM Create domain folders
mkdir domain\entities 2>nul
mkdir domain\repositories 2>nul
mkdir domain\usecases 2>nul

REM Create presentation folders
mkdir presentation\pages\admin 2>nul
mkdir presentation\pages\coach 2>nul
mkdir presentation\pages\player 2>nul
mkdir presentation\pages\auth 2>nul
mkdir presentation\widgets\common 2>nul
mkdir presentation\widgets\dialogs 2>nul
mkdir presentation\providers 2>nul

REM Move constants
move "utils\constants\*" "core\constants\" 2>nul

REM Move utils
move "utils\export_pdf.dart" "core\utils\" 2>nul
move "utils\shared_preferences_helper.dart" "core\utils\" 2>nul

REM Move providers
move "service\provider\*" "presentation\providers\" 2>nul

REM Move firebase services to datasources
move "service\firebase\*" "data\datasources\remote\" 2>nul

REM Move auth screens
move "pages\login_screen.dart" "presentation\pages\auth\" 2>nul
move "pages\signup_screen.dart" "presentation\pages\auth\" 2>nul
move "pages\splash_screen.dart" "presentation\pages\auth\" 2>nul

REM Move admin screens
move "pages\home_screen\admin_home.dart" "presentation\pages\admin\" 2>nul

REM Move coach screens
move "pages\home_screen\coach_home.dart" "presentation\pages\coach\" 2>nul
move "pages\coach_details.dart" "presentation\pages\coach\" 2>nul
move "pages\trainingTemplates.dart" "presentation\pages\coach\" 2>nul
move "pages\trainingTemplatesClone.dart" "presentation\pages\coach\" 2>nul

REM Move player screens
move "pages\home_screen\player_home.dart" "presentation\pages\player\" 2>nul
move "pages\player_details.dart" "presentation\pages\player\" 2>nul

REM Move widgets
move "widgets\error_popup.dart" "presentation\widgets\dialogs\" 2>nul
move "widgets\qr_popup.dart" "presentation\widgets\dialogs\" 2>nul
move "widgets\addExercisePage.dart" "presentation\widgets\dialogs\" 2>nul
move "widgets\*" "presentation\widgets\common\" 2>nul

REM Move controllers
move "controller\authWrapper.dart" "core\utils\" 2>nul
move "controller\role_based.dart" "core\utils\" 2>nul

REM Clean up empty directories
rmdir /s /q "pages\home_screen" 2>nul
rmdir /s /q "pages" 2>nul
rmdir /s /q "widgets" 2>nul
rmdir /s /q "controller" 2>nul
rmdir /s /q "service\firebase" 2>nul
rmdir /s /q "service\provider" 2>nul
rmdir /s /q "service" 2>nul
rmdir /s /q "utils\constants" 2>nul
rmdir /s /q "utils" 2>nul

echo.
echo Folder structure created successfully!
echo.
echo Clean Architecture Structure:
echo ├── core/
echo │   ├── constants/
echo │   ├── themes/
echo │   ├── utils/
echo │   └── errors/
echo ├── data/
echo │   ├── models/
echo │   ├── datasources/remote/
echo │   └── repositories/
echo ├── domain/
echo │   ├── entities/
echo │   ├── repositories/
echo │   └── usecases/
echo └── presentation/
echo     ├── pages/
echo     │   ├── admin/
echo     │   ├── coach/
echo     │   ├── player/
echo     │   └── auth/
echo     ├── widgets/
echo     │   ├── common/
echo     │   └── dialogs/
echo     └── providers/
echo.
echo Next: Run 'dart fix --dry-run' to check imports, then 'dart fix --apply' to fix them
pause
