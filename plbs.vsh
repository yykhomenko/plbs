#!/usr/bin/env -S v -skip-unused -gc none

import os

fn sh(cmd string) os.Result {
	println('> ${cmd}')
	result := execute_or_exit(cmd)
	println(result.output)
	return result
}

// rmdir_all('data') or {}
// mkdir('data') or {}

// sh('git clone --depth=1 https://github.com/attractivechaos/plb2 data/plb2')
data := read_lines('data/plb2/src/v/Makefile') or { panic('v Makefile is absent') }
strs := data.filter(fn (it string) bool {
	return it.starts_with('EXE=')
})
programs := strs.first().split('=').last().split(' ')

println(programs)

for prog in programs {
	sh('cd data/plb2/src/v && time ./${prog}')
}
