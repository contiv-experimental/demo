#!/usr/bin/env bats

# set environment variables for installer test
export CFG_FILE=${CFG_FILE:-${BATS_TEST_DIRNAME}/testdata/aci_cfg.yml}
export INTERACTIVE_MODE="no"

# set gloabl variables 
installer="${BATS_TEST_DIRNAME}/../net_demo_installer"

function print_output {
  for line in "${lines[@]}"; do
    echo ${line}
  done
}

@test "fresh install netplugin - aci mode " {
  run ${installer} -a
  print_output
  [ "${status}" -eq 0 ]
}

@test "clean and reinstall netplugin - aci mode" {
  run ${installer} -ar
  print_output
  [ "${status}" -eq 0 ]
}
