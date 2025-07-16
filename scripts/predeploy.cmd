@echo off
rem Azure Developer CLI Pre-deployment script for Windows

echo Running pre-deployment setup...

rem Set Node.js version
echo Setting Node.js version to 20...
set NODE_VERSION=20

rem Install dependencies for backend
echo Installing backend dependencies...
cd backend
call npm ci --only=production

rem Install dependencies for frontend  
echo Installing frontend dependencies...
cd ..\frontend
call npm ci

rem Install dependencies for admin
echo Installing admin dependencies...
cd ..\admin
call npm ci

cd ..

echo Pre-deployment setup complete!
