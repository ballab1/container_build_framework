#!/usr/bin/env bats

#Tests for log.lib
setup() {
  . "$BATS_TEST_DIRNAME/../01.bashlib/package.lib"

  rep_log=.
  script_nom=test_log
}

@test "DESCRIBE sflib_log_sortie" {
  command -v sflib_log_sortie
}

@test "DESCRIBE sflib_log_debug" {
  command -v sflib_log_init
}
