#!/bin/bash

function is_true() {
  [[ "$1" == "1" ]] || [[ "$1" == "true" ]]
}

function is_false() {
  [[ "$1" == "0" ]] || [[ "$1" == "false" ]]
}
