# Completion for ftinit
_ftinit() {
	_arguments \
		'-r[Initialize as git repository]' \
		'--repo[Initialize as git repository]' \
		'-f[Add .clang-format file]' \
		'--format[Add .clang-format file]'
}
compdef _ftinit ftinit

# Completion for gupdate
_gupdate() {
	_files -/
}
compdef _gupdate gupdate

# Completion for gitingest
_gitingest() {
	_arguments -C \
		'-i+[Include directory]:directory:_files -/' \
		'--include+[Include directory]:directory:_files -/' \
		'-e+[Exclude directory]:directory:_files -/' \
		'--exclude+[Exclude directory]:directory:_files -/' \
		'-o+[Only option]:option:(archi content)' \
		'--only+[Only option]:option:(archi content)' \
		'*:directory:_files -/'
}
compdef _gitingest gitingest

# Completion for hcreate
_hcreate() {
	_arguments \
		'--c[Custom option]' \
		'*:file:_files'
}
compdef _hcreate hcreate

# Completion for managedns
_managedns() {
	_values 'DNS State' on off state
}
compdef _managedns managedns

# Completion for wallpaperctl
_wallpaperctl() {
  local -a subcmds
  subcmds=('set:Set a specific wallpaper' 'rd:Set a random wallpaper')

  local wall_dir="${WALL_DIR:-$HOME/Pictures/wallpapers}"

  _arguments -C \
    "1:command:((set\:Set\ a\ wallpaper rd\:Set\ a\ random\ one))" \
    "2::image file:_files -W $wall_dir" \
    && return 0
}
compdef _wallpaperctl wallpaperctl

# Completion for powerctl
_powertctl() {
	_arguments -C \
	  "1:action:(suspend hibernate poweroff reboot)" \
	  "*:: :->args"	
}
compdef _powerctl powerctl
