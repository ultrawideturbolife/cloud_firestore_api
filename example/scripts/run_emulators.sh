#!/bin/bash

# Kill any processes using our ports
kill_port() {
    local port=$1
    local pid=$(lsof -t -i:$port)
    if [ ! -z "$pid" ]; then
        echo "Killing process on port $port"
        kill -9 $pid
    fi
}

# Kill processes on emulator ports
kill_port 8080  # Firestore
kill_port 4000  # Emulator UI

# Start emulators
firebase emulators:start 