#!/usr/bin/env -S v -skip-unused -gc none

import os
import strconv

struct BenchResult {
	name                         string
	source_lines                 u32
	source_size                  u32
	source_size_per_line         f32
	compile_size                 u32
	compile_size_per_source_size f32
	compile_duration             f32
	run_cpu                      f32
	run_memory                   f32
	run_duration                 f32
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
// sh('cd data/plb2/src/v && make clean')
// sh('cd data/plb2/src/v && make all')

//
for prog in programs {
	lines := read_lines('data/plb2/src/v/${prog}.v') or { panic('v file is absent') }
	source_lines := u32(lines.len)
	source_size := u32(os.file_size('data/plb2/src/v/${prog}.v'))
	source_size_per_line := f32(source_size) / source_lines
	compile_size := u32(os.file_size('data/plb2/src/v/${prog}'))
	compile_size_per_source_size := f32(compile_size) / f32(source_size)

	ms := sh('cd data/plb2/src/v && time ./${prog}').output
		.split_into_lines().filter(it.starts_with('real')).first()
		.split('real').last().trim_space()
		.split('m')
	minutes_str := ms.first().trim_space()
	seconds_str := ms.last().split('s').first().trim_space()
	minutes := strconv.atoi(minutes_str) or { panic('unable to parse minutes') }
	seconds := strconv.atof64(seconds_str) or { panic('unable to parse seconds') }
	run_duration := f32(minutes * 60 + seconds)

	b := BenchResult{
		name:                         prog
		source_lines:                 source_lines
		source_size:                  source_size
		source_size_per_line:         source_size_per_line
		compile_size:                 compile_size
		compile_size_per_source_size: compile_size_per_source_size
		compile_duration:             0
		run_cpu:                      0
		run_memory:                   0
		run_duration:                 run_duration
	}

	println(b)
}
