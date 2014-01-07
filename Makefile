all:
	mkdir -p ${HOME}/.config
	ln -fs `pwd` ${HOME}/.config/awesome
	ln -fs `pwd`/gtkrc-2.0 ${HOME}/.gtkrc-2.0
	git clone "https://github.com/gorlowski/couth.git" couth_install
	cd couth_install && make install
