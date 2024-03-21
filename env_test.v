module dotenv

import os

fn assert_defaults(parsed map[string]string) {
	assert parsed['VAR'] == 'VAL'
	assert os.getenv('VAR') == 'VAL'
	assert parsed['QUOTED'] == 'VAL'
	assert os.getenv('QUOTED') == 'VAL'
	assert parsed['SQUOTED'] == 'VAL'
	assert os.getenv('SQUOTED') == 'VAL'
	assert parsed['INLINE_QUOTED'] == 'VAL'
	assert os.getenv('INLINE_QUOTED') == 'VAL'
	assert parsed['CASI_INLINE_QUOTED'] == 'VAL# not a comment'
	assert os.getenv('CASI_INLINE_QUOTED') == 'VAL# not a comment'
	assert parsed['COMMENT_ENCLOSED_IN_QUOTES'] == 'VAL # not a comment'
	assert os.getenv('COMMENT_ENCLOSED_IN_QUOTES') == 'VAL # not a comment'
	assert parsed['COMMENT_OUTSIDE_QUOTES'] == 'VAL'
	assert os.getenv('COMMENT_OUTSIDE_QUOTES') == 'VAL'
	assert parsed['ESCAPED_SQUOTE'] == "Let's go!"
	assert os.getenv('ESCAPED_SQUOTE') == "Let's go!"
	assert parsed['ESCAPED_QUOTE'] == '{"hello": "json"}'
	assert os.getenv('ESCAPED_QUOTE') == '{"hello": "json"}'
	assert parsed['QUOTED_TAB_ESCAPE'] == 'some\tvalue'
	assert os.getenv('QUOTED_TAB_ESCAPE') == 'some\tvalue'
	assert parsed['SQUOTED_NO_TAB_ESCAPE'] == 'some\\tvalue'
	assert os.getenv('SQUOTED_NO_TAB_ESCAPE') == 'some\\tvalue'
	assert parsed['UNQUOTED_NO_TAB_ESCAPE'] == 'some\\tvalue'
	assert os.getenv('UNQUOTED_NO_TAB_ESCAPE') == 'some\\tvalue'
}

fn test_parse_default_env_file() {
	parsed := load()!
	assert_defaults(parsed)
}

fn test_parse_specified_env_file() {
	parsed := load('env_file')!
	assert_defaults(parsed)
}

fn test_parse_multiple_env_files() {
	parsed := load('env_file', 'extra_env_file')!
	assert_defaults(parsed)
	assert parsed['EXTRA_VAL'] == 'ABC'
	assert os.getenv('EXTRA_VAL') == 'ABC'
}
