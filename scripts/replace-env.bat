set envPath=env
set env=%1

if "%env%" == "" echo "No environment supplied, allowed: [dev, prod]" & exit 1

copy "%envPath%\%env%.env" "%envPath%\.env"
echo "Copied '%envPath%\%env%.env' to '%envPath%\.env'"