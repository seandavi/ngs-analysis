#!/bin/bash

# Create a directory if it doesn't already exist
create_dir() {
  [ ! -d $1 ] && mkdir $1
}
