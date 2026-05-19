#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")"

echo "========================================"
echo "Starting Catalyst Local Environment"
echo "========================================"

# Check for .env files
if [ ! -f "verdictai-backend/.env" ]; then
    echo "⚠️ Warning: verdictai-backend/.env is missing. You may want to copy verdictai-backend/.env.example to verdictai-backend/.env and fill in the values."
fi

if [ ! -f ".env" ]; then
    echo "⚠️ Warning: .env is missing in the frontend directory. You may want to copy .env.example to .env and fill in the values."
fi

# 1. Setup Backend
echo "----------------------------------------"
echo "Setting up backend..."
cd verdictai-backend

# Check if venv exists, if not create it
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate venv and install requirements
echo "Activating virtual environment and installing dependencies..."
source venv/bin/activate
pip install -r requirements.txt

# Start backend in the background
echo "Starting backend server on port 8000..."
uvicorn main:app --host 127.0.0.1 --port 8000 --reload &
BACKEND_PID=$!

# Go back to frontend root
cd ..

# 2. Setup Frontend
echo "----------------------------------------"
echo "Setting up frontend..."

# Install node modules if needed
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

# Start frontend server
echo "Starting frontend development server..."
npm run dev &
FRONTEND_PID=$!

echo "========================================"
echo "🚀 Environment is up and running!"
echo " Backend: http://127.0.0.1:8000"
echo " Frontend is starting (check output above for the exact local URL, usually http://localhost:5173)"
echo " Press Ctrl+C to stop all servers."
echo "========================================"

# Trap Ctrl+C to kill both background processes
trap "echo 'Stopping servers...'; kill $BACKEND_PID $FRONTEND_PID; exit" INT

# Wait for both processes to keep the script running
wait
