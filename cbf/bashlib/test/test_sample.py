#!/usr/bin/python
import subprocess
import os

def run(cb, cmd):
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    cb(out, err)

def test_answer():
    def cb(a,b):
      assert a == b
      return
    assert run(cb, 'grafana.GetHomeDashboard') == 5
