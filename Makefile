all:
	mkdir -p ${HOME}/.config
	ln -fs `pwd` ${HOME}/.config/awesome
	git clone "https://github.com/gorlowski/couth.git" couth_install
	cd couth_install && make install
