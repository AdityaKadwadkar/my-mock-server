@echo off
set API_URL=http://localhost:3001/api

echo Uploading Courses...
curl.exe -X POST -F "file=@courses.csv" %API_URL%/upload/courses
echo.
echo.

echo Uploading Students...
curl.exe -X POST -F "file=@students.csv" %API_URL%/upload/students
echo.
echo.

echo Uploading Enrollments...
curl.exe -X POST -F "file=@enrollments.csv" %API_URL%/upload/enrollments
echo.
echo.

echo Uploading Marks...
curl.exe -X POST -F "file=@marks.csv" %API_URL%/upload/marks
echo.
echo.

echo --- Verifying GET endpoints ---
echo.

echo Fetching Courses...
curl.exe %API_URL%/courses
echo.
echo.

echo Fetching Students...
curl.exe %API_URL%/students
echo.
echo.

echo Fetching Enrollments...
curl.exe %API_URL%/enrollments
echo.
echo.

echo Fetching Marks...
curl.exe %API_URL%/marks
echo.
echo.
