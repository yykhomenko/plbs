#!/usr/bin/env -S v -skip-unused -gc none

import os
import strconv

struct BenchResult {
	name                  string
	source_lines          u32
	source_bytes          u32
	source_bytes_per_line f32
	bin_size              u32
	duration              f32
}

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
// -------------------------------------------
//
for prog in programs {
	output := sh('cd data/plb2/src/v && time ./${prog}').output
	duration_str := output.split_into_lines().filter(fn (it string) bool {
		return it.starts_with('real')
	}).first().split('real').last().trim_space()
	ms := duration_str.split('m')
	minutes_str := ms.first().trim_space()
	seconds_str := ms.last().split('s').first().trim_space()
	minutes := strconv.atoi(minutes_str) or { panic('unable to parse minutes') }
	seconds := strconv.atof64(seconds_str) or { panic('unable to parse seconds') }
	duration := f32(minutes * 60 + seconds)

	lines := read_lines('data/plb2/src/v/${prog}.v') or { panic('v file is absent') }
	source_lines := u32(lines.len)
	source_bytes := u32(os.file_size('data/plb2/src/v/${prog}.v'))
	source_bytes_per_line := f32(source_bytes) / source_lines
	bin_size := u32(os.file_size('data/plb2/src/v/${prog}'))

	b := BenchResult{
		name:                  prog
		source_lines:          source_lines
		source_bytes:          source_bytes
		source_bytes_per_line: source_bytes_per_line
		bin_size:              bin_size
		duration:              duration
	}

	println(b)
}
