#!/usr/bin/env -S v -skip-unused -gc none

import os

fn sh(cmd string) os.Result {
	println('> ${cmd}')
	result := execute_or_exit(cmd)
	// println(result.output)
	return result
}

// rmdir_all('data') or {}
// mkdir('data') or {}

// sh('git clone --depth=1 https://github.com/attractivechaos/plb2 data/plb2')
rmdir_all('data/plb2/.git') or {}
data := read_lines('data/plb2/src/v/Makefile') or { panic('v Makefile is absent') }
strs := data.filter(fn (it string) bool {
	return it.starts_with('EXE=')
})
programs := strs.first().split('=').last().split(' ')

println(programs)

for prog in programs {
	output := sh('cd data/plb2/src/v && time ./${prog}').output

	time := output.split_into_lines().filter(fn (it string) bool {
		return it.starts_with('real')
	}).first().split('real').last().trim_space()

	source_size := os.file_size('data/plb2/src/v/${prog}.v')
	bin_size := os.file_size('data/plb2/src/v/${prog}')
	lines := read_lines('data/plb2/src/v/${prog}.v') or { panic('v file is absent') }
	lines_num := lines.len
	bpl := f64(source_size) / lines_num

	println('${prog}: ${time}')
	println('lines:\t\t${lines_num}')
	println('source size:\t${source_size} bytes')
	println('byte per line:\t${bpl}')
	println('binary size:\t${bin_size} bytes')
}
