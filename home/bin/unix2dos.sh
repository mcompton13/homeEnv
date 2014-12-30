#!/bin/bash

# Convert to DOS line endings (add CRs)
sed -i '' -e 's/$/'$'\r/' "$@"
