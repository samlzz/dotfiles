#!/usr/bin/env bash

main()
{
	local files="$@"
	
	for f in $files; do
		if [ -f "$f" ]; then
			(systemctl --user daemon-reload && \
				systemctl --user enable --now "$f") || \
				echo "activate: failed to enable '$f'"
		else
			echo "activate: service '$f' not found"
		fi
	done
}

USER_SERVICES_DIR="$HOME/.config/systemd"

main "$USER_SERVICES_DIR/"*.service
