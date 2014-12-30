#!/bin/bash

# Convert to UNIX line endings (remove CRs)
sed -i '' -e $'s/\r$//' "$@"
