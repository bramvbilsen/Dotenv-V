// Uses the following spec: https://docs.docker.com/compose/environment-variables/env-file/

module dotenv

import os

// Assigns the variables in the env files to the environment of the process and returns a map containing all the key/value pairs found in the environment files.
// Falls back to `.env` when no file paths are provided.
pub fn load(_filepaths ...string) !map[string]string {
	mut env_map := map[string]string{}
	filepaths := if _filepaths.len == 0 { ['.env'] } else { _filepaths }
	println(filepaths)
	for filepath in filepaths {
		for key, val in load_file(filepath)! {
			env_map[key] = val
			os.setenv(key, val, true)
		}
	}
	return env_map
}

fn load_file(path string) !map[string]string {
	mut vars := map[string]string{}
	lines := os.read_lines(path)!
	for line in lines {
		if line.starts_with('#') {
			continue
		}
		name, val := line.split_once('=') or { '', '' }
		trimmed_val := val.trim_space()
		if name.len != name.trim_space().len || val[0] != trimmed_val[0] {
			return error('No whitespaces allowed between `=`, name and value')
		}
		if trimmed_val == '' {
			return error('Non comment line without NAME=value structure')
		}
		if trimmed_val.runes()[0] in [`"`, `'`] {
			closing_index := trimmed_val.index_u8_last(trimmed_val[0])
			if closing_index == 0 {
				return error('Value starting with a quote (\' or ") should be closed')
			}
			enclosed_string := trimmed_val[1..closing_index]
			for index, c in enclosed_string {
				if (c == "'"[0] || c == '"'[0])
					&& (index == 0 || enclosed_string[index - 1] != '\\'[0]) {
					return error('Unescaped quotes in quoted value')
				}
			}
			if closing_index + 1 < trimmed_val.len {
				not_enclosed_string := trimmed_val[closing_index + 1..trimmed_val.len].trim_space()
				if not_enclosed_string.len > 0 && !not_enclosed_string.starts_with('#') {
					return error('Unexpected characters after quoted value')
				}
			}

			vars[name] = match trimmed_val[0] == '"'[0] {
				true {
					enclosed_string.replace('\\"', '"')
						.replace('\\n', '\n')
						.replace('\\r', '\r')
						.replace('\\t', '\t')
						.replace('\\', r'\')
				}
				// Only the single quotes are escaped for single quoted strings
				false {
					enclosed_string.replace("\\'", "'")
				}
			}
		} else {
			hash_start_index := trimmed_val.index('#') or { -1 }
			if hash_start_index == -1 || hash_start_index == 0
				|| trimmed_val[hash_start_index - 1] != ' '[0] {
				vars[name] = trimmed_val
			} else {
				vars[name] = trimmed_val[0..hash_start_index].trim_space()
			}
		}
	}
	return vars
}
